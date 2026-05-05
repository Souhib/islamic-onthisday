"""Structural + editorial-invariant validation across the curated DB.

Run after ``pipeline.build`` to catch malformed citations + bad invariants:

    uv run python -m pipeline.validate

Reference validation:
* ``quran_refs`` — every ``surah:ayah[-ayah]`` pair points to a real surah and
  in-range ayah (using the canonical ayah-count table for the Kufan ḥafs
  count of the Qur'an: 114 surahs, 6,236 verses).
* ``hadith_refs`` — every ``Collection N`` follows the well-formed pattern;
  the collection name is one of the recognised ones; the number is positive.

Editorial invariants:
* **`disputed=True` requires `verification_status >= cross_verified`.**
  The disputed flag means "the date or a small detail is contested across
  classical sources" — the *event itself* must therefore be confirmed by
  ≥2 independent classical Sunni sources. An unverified or single-source
  event has no business being marked disputed; either it can be promoted
  with a second source, the disputed flag should be removed, or the event
  should be dropped.

Outputs a Markdown report to ``data/output/validation_report.md`` plus a
console summary, and exits with code 1 on any failure so CI can gate on it.
"""

import re
import sys
from collections.abc import Iterable
from pathlib import Path

from rich.console import Console
from sqlmodel import select

from pipeline.constants import OUTPUT_DIR
from pipeline.database import session_scope
from pipeline.models.db import DatelessLesson, Event, Observance

console = Console()

REPORT_PATH: Path = OUTPUT_DIR / "validation_report.md"

# Verses-per-surah — Kufan / Hafs count, the dominant printed text.
SURAH_AYAH_COUNTS: tuple[int, ...] = (
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,  # 1-10
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,  # 11-20
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,  # 21-30
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,  # 31-40
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,  # 41-50
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,  # 51-60
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,  # 61-70
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,  # 71-80
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,  # 81-90
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,  # 91-100
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,  # 101-110
    5,
    4,
    5,
    6,  # 111-114
)

# Recognised verification statuses, in order of strength.
#   unverified      — provisional, awaiting editorial review
#   single_source   — 1 classical Sunni source cited in YAML
#   cross_verified  — ≥2 classical Sunni sources cited
#   scholar_reviewed— a qualified Muslim scholar has signed off
#   needs_review    — flagged by a curator for re-evaluation
KNOWN_VERIFICATION_STATUSES: frozenset[str] = frozenset(
    {"unverified", "single_source", "cross_verified", "scholar_reviewed", "needs_review"}
)

# An event marked ``disputed: true`` must already have its existence
# confirmed by ≥2 independent classical sources — otherwise we don't even
# know the event happened, and "the dispute" is meaningless. Promotions to
# this set may happen as new sources are added; demotions never happen
# without a corrected source.
DISPUTED_REQUIRES_STATUS: frozenset[str] = frozenset({"cross_verified", "scholar_reviewed"})

# When ``disputed`` is true, ``dispute_about`` must be one of these — the
# frontend uses it to calibrate how prominently the dispute is surfaced.
ALLOWED_DISPUTE_ABOUT: frozenset[str] = frozenset({"date", "detail", "interpretation"})


# Recognised hadith collections. Anything outside this list is flagged.
KNOWN_HADITH_COLLECTIONS: frozenset[str] = frozenset(
    {
        "Bukhari",
        "Sahih al-Bukhari",
        "Muslim",
        "Sahih Muslim",
        "Tirmidhi",
        "Jami' at-Tirmidhi",
        "Abu Dawud",
        "Sunan Abi Dawud",
        "Nasa'i",
        "Sunan an-Nasa'i",
        "Ibn Majah",
        "Sunan Ibn Majah",
        "Muwatta",
        "Muwatta Malik",
        "Musnad Ahmad",
        "Darimi",
        "Sunan al-Darimi",
        "Riyad as-Salihin",
        "Hakim",
        "al-Hakim",
        "Mustadrak al-Hakim",
        "Sahih al-Targhib",
        "al-Targhib",
        "al-Targhib wa al-Tarhib",
    }
)

# "2:255", "3:97", "2:127-129" — also accepts "al-Nūr 24:31", "Āl ʿImrān 3:130"
QURAN_REF_RE = re.compile(
    r"^\s*(?:[\w\s\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF'ʿʾ-]+?\s+)?"
    r"(\d{1,3})\s*:\s*(\d{1,3})(?:\s*[-–]\s*(\d{1,3}))?\s*$"
)
# "Bukhari 3", "Sahih al-Bukhari 5027", "Muslim 2444"
HADITH_REF_RE = re.compile(r"^\s*(.+?)\s+(\d{1,5})\s*$")


def _split_refs(raw: str | None) -> list[str]:
    """Split a comma-separated refs string into individual reference tokens.

    Args:
        raw: The raw string from ``quran_refs`` / ``hadith_refs`` columns.

    Returns:
        A list of trimmed, non-empty reference tokens.
    """
    if not raw:
        return []
    return [tok.strip() for tok in raw.split(",") if tok.strip()]


def _validate_quran_ref(ref: str) -> str | None:
    """Return None if ``ref`` is a valid Qur'anic citation, else an error string.

    Args:
        ref: A single reference token like ``"2:255"`` or ``"18:9-26"``.

    Returns:
        ``None`` on success; a human-readable error message on failure.
    """
    match = QURAN_REF_RE.match(ref)
    if not match:
        return f"malformed (expected 'S:A' or 'S:A-B'): '{ref}'"
    surah = int(match.group(1))
    start = int(match.group(2))
    end = int(match.group(3)) if match.group(3) else start
    if not (1 <= surah <= 114):
        return f"surah out of range (1-114): {surah} in '{ref}'"
    max_ayah = SURAH_AYAH_COUNTS[surah - 1]
    if not (1 <= start <= max_ayah):
        return f"start ayah {start} out of range for surah {surah} (1-{max_ayah}): '{ref}'"
    if not (start <= end <= max_ayah):
        return f"end ayah {end} out of range for surah {surah} (1-{max_ayah}): '{ref}'"
    return None


def _validate_hadith_ref(ref: str) -> str | None:
    """Return None if ``ref`` is a valid hadith citation, else an error string.

    Args:
        ref: A single reference token like ``"Bukhari 3"``.

    Returns:
        ``None`` on success; a human-readable error message on failure.
    """
    match = HADITH_REF_RE.match(ref)
    if not match:
        return f"malformed (expected 'Collection N'): '{ref}'"
    collection = match.group(1).strip()
    if collection not in KNOWN_HADITH_COLLECTIONS:
        return f"unknown collection '{collection}' in '{ref}'"
    number = int(match.group(2))
    if number < 1:
        return f"non-positive hadith number in '{ref}'"
    return None


def _check_record(slug: str, kind: str, quran_raw: str | None, hadith_raw: str | None) -> list[str]:
    """Validate one event/lesson/observance record and return any error strings.

    Args:
        slug: Stable slug of the record being validated.
        kind: ``"event"`` / ``"lesson"`` / ``"observance"`` for the report.
        quran_raw: Raw ``quran_refs`` value or ``None``.
        hadith_raw: Raw ``hadith_refs`` value or ``None``.

    Returns:
        A list of error lines; empty if the record passes.
    """
    errors: list[str] = []
    for ref in _split_refs(quran_raw):
        err = _validate_quran_ref(ref)
        if err:
            errors.append(f"  - {kind} `{slug}` quran_refs: {err}")
    for ref in _split_refs(hadith_raw):
        err = _validate_hadith_ref(ref)
        if err:
            errors.append(f"  - {kind} `{slug}` hadith_refs: {err}")
    return errors


def _check_verification_status(event: Event) -> str | None:
    """Verify ``event.verification_status`` is one of the recognised values.

    Args:
        event: The event row to validate.

    Returns:
        ``None`` when the status is recognised; an error message otherwise.
    """
    if event.verification_status in KNOWN_VERIFICATION_STATUSES:
        return None
    return (
        f"  - event `{event.slug}` has unknown verification_status "
        f"`{event.verification_status}` (must be one of "
        f"{sorted(KNOWN_VERIFICATION_STATUSES)})"
    )


def _check_disputed_invariant(event: Event) -> list[str]:
    """Verify ``event.disputed`` is consistent with verification + dispute_about.

    Two invariants live here:

    1. ``disputed=true`` requires ``verification_status >= cross_verified`` —
       the event itself must already be confirmed by ≥2 independent classical
       Sunni sources before a dispute can be claimed.
    2. ``disputed=true`` requires ``dispute_about ∈ {date, detail,
       interpretation}`` — the frontend needs to know what *kind* of dispute
       it is so it can calibrate how prominently to surface it.

    Args:
        event: The event row to validate.

    Returns:
        A list of error message lines (empty when both invariants hold).
    """
    if not event.disputed:
        return []
    errors: list[str] = []
    if event.verification_status not in DISPUTED_REQUIRES_STATUS:
        errors.append(
            f"  - event `{event.slug}` violates `disputed→cross_verified` invariant: "
            f"`disputed=true` with `verification_status={event.verification_status}` "
            "(needs ≥2 independent classical sources before a dispute can be claimed)"
        )
    if event.dispute_about not in ALLOWED_DISPUTE_ABOUT:
        errors.append(
            f"  - event `{event.slug}` violates `disputed→dispute_about` invariant: "
            f"`disputed=true` with `dispute_about={event.dispute_about!r}` "
            "(must be one of 'date', 'detail', 'interpretation')"
        )
    return errors


def _collect_errors() -> tuple[list[str], dict[str, int]]:
    """Run all checks and gather error lines + totals.

    Returns:
        A 2-tuple ``(errors, counts)``: a list of error message lines and a
        dict of per-kind totals (records-checked / records-with-errors / refs /
        invariant violations).
    """
    errors: list[str] = []
    counts = {
        "events_checked": 0,
        "events_with_errors": 0,
        "lessons_checked": 0,
        "lessons_with_errors": 0,
        "observances_checked": 0,
        "observances_with_errors": 0,
        "total_quran_refs": 0,
        "total_hadith_refs": 0,
        "disputed_events": 0,
        "disputed_invariant_violations": 0,
    }
    with session_scope() as session:
        for event in session.exec(
            select(Event).where(Event.quran_refs.isnot(None) | Event.hadith_refs.isnot(None))
        ).all():
            counts["events_checked"] += 1
            counts["total_quran_refs"] += len(_split_refs(event.quran_refs))
            counts["total_hadith_refs"] += len(_split_refs(event.hadith_refs))
            record_errors = _check_record(event.slug, "event", event.quran_refs, event.hadith_refs)
            if record_errors:
                counts["events_with_errors"] += 1
                errors.extend(record_errors)

        # Invariant pass — every disputed event, regardless of refs.
        for event in session.exec(select(Event).where(Event.disputed.is_(True))).all():
            counts["disputed_events"] += 1
            invariant_errors = _check_disputed_invariant(event)
            if invariant_errors:
                counts["disputed_invariant_violations"] += 1
                errors.extend(invariant_errors)

        for lesson in session.exec(
            select(DatelessLesson).where(DatelessLesson.quran_refs.isnot(None) | DatelessLesson.hadith_refs.isnot(None))
        ).all():
            counts["lessons_checked"] += 1
            counts["total_quran_refs"] += len(_split_refs(lesson.quran_refs))
            counts["total_hadith_refs"] += len(_split_refs(lesson.hadith_refs))
            record_errors = _check_record(lesson.slug, "lesson", lesson.quran_refs, lesson.hadith_refs)
            if record_errors:
                counts["lessons_with_errors"] += 1
                errors.extend(record_errors)

        for obs in session.exec(
            select(Observance).where(Observance.quran_refs.isnot(None) | Observance.hadith_refs.isnot(None))
        ).all():
            counts["observances_checked"] += 1
            counts["total_quran_refs"] += len(_split_refs(obs.quran_refs))
            counts["total_hadith_refs"] += len(_split_refs(obs.hadith_refs))
            record_errors = _check_record(obs.slug, "observance", obs.quran_refs, obs.hadith_refs)
            if record_errors:
                counts["observances_with_errors"] += 1
                errors.extend(record_errors)
    return errors, counts


def _format_report(errors: Iterable[str], counts: dict[str, int]) -> str:
    """Build the Markdown report body.

    Args:
        errors: Iterable of error message lines.
        counts: Per-kind tallies from :func:`_collect_errors`.

    Returns:
        A Markdown-formatted report string.
    """
    error_list = list(errors)
    lines: list[str] = []
    lines.append("# Validation report\n")
    lines.append(f"**Quran refs checked:** {counts['total_quran_refs']}  ")
    lines.append(f"**Hadith refs checked:** {counts['total_hadith_refs']}  ")
    lines.append(f"**Disputed events:** {counts['disputed_events']}  ")
    lines.append(f"**Disputed-invariant violations:** {counts['disputed_invariant_violations']}  ")
    lines.append("")
    lines.append("| Kind | Records checked | With errors |")
    lines.append("| ---- | ---: | ---: |")
    lines.append(f"| Events | {counts['events_checked']} | {counts['events_with_errors']} |")
    lines.append(f"| Lessons | {counts['lessons_checked']} | {counts['lessons_with_errors']} |")
    lines.append(f"| Observances | {counts['observances_checked']} | {counts['observances_with_errors']} |")
    lines.append("")
    if error_list:
        lines.append(f"## Errors ({len(error_list)})\n")
        lines.extend(error_list)
    else:
        lines.append("## Errors\n")
        lines.append("**None — all references are well-formed.**")
    lines.append("")
    lines.append("## Notes")
    lines.append("- Reference validation is purely structural: surah/ayah ranges and collection-name format.")
    lines.append(
        "- It does NOT verify that the cited hadith says what we describe — that requires deep validation against sunnah.com or a local Sahih corpus mirror (e.g. AhmedBaset/hadith-json)."
    )
    lines.append("- Quran ayah-count table is the Kufan/Hafs count (114 surahs, 6,236 verses).")
    lines.append(
        "- Editorial invariant: any event with `disputed: true` must already be `verification_status >= cross_verified`."
    )
    return "\n".join(lines)


def main() -> None:
    """CLI entry point — run validation, write a Markdown report, exit non-zero on failure."""
    errors, counts = _collect_errors()
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(_format_report(errors, counts))
    if errors:
        console.print(
            f"[red]{len(errors)} validation issues found "
            f"({counts['disputed_invariant_violations']} disputed-invariant).[/] Report: {REPORT_PATH}"
        )
        sys.exit(1)
    console.print(
        f"[green]All {counts['total_quran_refs']} Qur'an refs, "
        f"{counts['total_hadith_refs']} hadith refs, and "
        f"{counts['disputed_events']} disputed events pass.[/] Report: {REPORT_PATH}"
    )


if __name__ == "__main__":
    main()

"""Generate ``web/public/dataset-meta.json`` — dataset depth signal for the FE footer.

Mirrors the static-asset model used by :mod:`pipeline.syndication`:
the pipeline owns the dataset, so the pipeline computes the public
profundity stat (event count, sacred-day count, person count, days
covered) once per build and ships it as a static JSON the FE fetches
on mount. No backend endpoint, no runtime queries — same posture as
``sitemap.xml`` / ``feed.xml``.
"""

import json
from datetime import UTC, datetime
from pathlib import Path

from sqlmodel import Session, func, select

from pipeline.constants import PROJECT_ROOT
from pipeline.database import session_scope
from pipeline.models.db import Event, Observance, Person

DEFAULT_OUTPUT_DIR: Path = PROJECT_ROOT.parent / "web" / "public"

# Mirror of the headline-eligibility ladder in
# ``backend/iotd/api/constants.py`` and ``syndication.py``. Tier-1 events
# are what the FE Today route surfaces, so this is the right metric for
# the public footer signal.
_HEADLINE_IMPORTANCE: tuple[str, ...] = ("major", "notable")
_HEADLINE_VERIFICATION_STATUSES: tuple[str, ...] = (
    "single_source",
    "cross_verified",
    "scholar_reviewed",
)


def write_dataset_meta(*, output_dir: Path | None = None) -> Path:
    """Compute the dataset depth stats and write ``dataset-meta.json``.

    The frontend reads this file on mount to populate the footer
    profundity signal. Missing file = footer skips the stat (graceful
    degradation on a fresh clone before the first build).

    Args:
        output_dir: Where to write ``dataset-meta.json``. Defaults to
            ``<repo>/web/public/``.

    Returns:
        The path that was written.
    """
    out = output_dir or DEFAULT_OUTPUT_DIR
    out.mkdir(parents=True, exist_ok=True)
    target = out / "dataset-meta.json"

    with session_scope() as session:
        payload = _compute(session)

    target.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return target


def _compute(session: Session) -> dict[str, int | str]:
    """Build the JSON payload from a fresh DB session."""
    event_count = session.exec(select(func.count(Event.id))).one()
    observance_count = session.exec(select(func.count(Observance.id))).one()
    person_count = session.exec(select(func.count(Person.id))).one()
    days_with_headline = session.exec(
        select(func.count(func.distinct(Event.display_gregorian_doy)))
        .where(Event.importance.in_(_HEADLINE_IMPORTANCE))
        .where(Event.verification_status.in_(_HEADLINE_VERIFICATION_STATUSES))
    ).one()

    return {
        "event_count": int(event_count),
        "observance_count": int(observance_count),
        "person_count": int(person_count),
        "days_with_headline": int(days_with_headline),
        "generated_at": datetime.now(UTC).isoformat(timespec="seconds").replace("+00:00", "Z"),
    }

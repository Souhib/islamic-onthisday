"""Safe image fetcher — religious prohibition enforcement.

Rules:

1. HARD BLOCK any image on a :class:`Person` row flagged
   ``is_prophet`` / ``is_sahabi`` / ``is_ahl_al_bayt``. This is the
   non-negotiable rule.
2. For Wikidata-imported persons, heuristically block images where the name
   matches known Sahabi patterns (Karbala martyrs, Banu Hashim, close
   Companions).
3. As a further precaution, block images on any Wikidata-imported person
   whose death year is before
   :data:`pipeline.constants.EARLY_ISLAM_CUTOFF_YEAR` — this conservatively
   covers the Sahaba, Tabi'un, and Tabi' al-Tabi'in generations.
4. Null any event image that is linked to a restricted person.

This module does not download images. Downloading + local mirroring is a
Phase-2 concern.
"""

from rich.console import Console
from sqlmodel import Session, select

from pipeline.constants import (
    EARLY_ISLAM_CUTOFF_YEAR,
    HIJRI_EPOCH_GREGORIAN_YEAR,
    HIJRI_TO_GREGORIAN_RATIO,
)
from pipeline.models.db import Event, Person

console = Console()

BLOCKED_NAME_KEYWORDS: tuple[str, ...] = (
    "prophet",
    "rasul",
    "muhammad",
    "sahab",
    "abu bakr",
    "umar ibn",
    "uthman ibn",
    "ali ibn",
    "ali al-",
    "ali bin",
    "fatima",
    "fatimah",
    "hasan ibn",
    "husayn ibn",
    "khadija",
    "aisha",
    "hamza ibn",
    "khalid ibn",
    "abu hurayra",
    "bilal",
    "abbas ibn",
    "ja'far ibn",
    "ja'far bin",
    "abd allah ibn abbas",
    "talha",
    "zubayr",
    "sa'd ibn",
    "salman al-farisi",
    "karbala",
)


def _looks_like_person_name(label: str | None) -> bool:
    """Return True when the label matches any Sahabi-style pattern.

    Args:
        label: The person's full English name, or None.

    Returns:
        True if any BLOCKED_NAME_KEYWORDS substring is present.
    """
    lowered = (label or "").lower()
    return any(keyword in lowered for keyword in BLOCKED_NAME_KEYWORDS)


def _person_death_year(session: Session, person: Person) -> int | None:
    """Approximate the Gregorian death year of a Wikidata-imported person.

    Looks up the ``scholar_death`` event linked by the same Wikidata QID.
    Falls back to a coarse Hijri-to-Gregorian approximation when only the
    Hijri year is known.

    Args:
        session: An open SQLAlchemy session.
        person: The Person record under consideration.

    Returns:
        An integer year, or None if no linked death event is found.
    """
    death_event = session.exec(
        select(Event).where(Event.wikidata_qid == person.wikidata_qid).where(Event.category == "scholar_death")
    ).first()
    if death_event is None:
        return None
    if death_event.canonical_gregorian_date is not None:
        return death_event.canonical_gregorian_date.year
    if death_event.canonical_hijri_year is not None:
        return int(HIJRI_EPOCH_GREGORIAN_YEAR + death_event.canonical_hijri_year * HIJRI_TO_GREGORIAN_RATIO)
    return None


def _apply_hard_rule(person: Person) -> bool:
    """Enforce the non-negotiable block for prophets/sahaba/ahl al-bayt.

    Args:
        person: The Person to evaluate (mutated in place).

    Returns:
        True if the image was blocked by this rule, False otherwise.
    """
    if not (person.is_prophet or person.is_sahabi or person.is_ahl_al_bayt):
        return False
    blocked = person.image_url is not None
    person.image_url = None
    if person.image_blocked_reason is None:
        person.image_blocked_reason = "religious_prohibition"
    return blocked


def _apply_heuristic_rules(session: Session, person: Person) -> bool:
    """Apply the Wikidata-import heuristics (name + death year).

    Args:
        session: Open SQLAlchemy session (used for death-year lookup).
        person: The Person under evaluation (mutated in place).

    Returns:
        True if the heuristic blocked an image, False otherwise.
    """
    if person.image_url is None:
        return False

    matches_name = _looks_like_person_name(person.full_name_en)
    death_year = _person_death_year(session, person)
    early_era = death_year is not None and death_year < EARLY_ISLAM_CUTOFF_YEAR

    if not (matches_name or early_era):
        return False

    reason = "heuristic_early_islamic_era" if early_era else "heuristic_sahabi_name_match"
    console.log(f"[yellow]Heuristic-blocking image on person {person.slug} ({reason})[/]")
    person.image_url = None
    person.image_blocked_reason = reason
    return True


def _block_event_image_if_restricted(event: Event) -> bool:
    """Null an event's image if any linked person is religiously restricted.

    Args:
        event: The Event under evaluation (mutated in place).

    Returns:
        True if the event image was blocked, False otherwise.
    """
    if event.image_url is None:
        return False

    has_restricted = any(
        link.person.is_prophet or link.person.is_sahabi or link.person.is_ahl_al_bayt for link in event.people_links
    )
    if not (has_restricted or _looks_like_person_name(event.title_en)):
        return False

    console.log(f"[yellow]Blocking image on event {event.slug} (linked person under religious_prohibition)[/]")
    event.image_url = None
    event.image_attribution = None
    event.image_license = None
    return True


def fetch_safe_images(session: Session) -> dict[str, int]:
    """Enforce image-safety rules over the entire database.

    Args:
        session: An open SQLAlchemy session.

    Returns:
        A dict with counts of persons/events whose images were nullified.
    """
    counts: dict[str, int] = {"persons_blocked": 0, "events_blocked": 0}

    for person in session.exec(select(Person)).all():
        if _apply_hard_rule(person):
            counts["persons_blocked"] += 1
            continue
        if _apply_heuristic_rules(session, person):
            counts["persons_blocked"] += 1

    for event in session.exec(select(Event)).all():
        if _block_event_image_if_restricted(event):
            counts["events_blocked"] += 1

    session.flush()
    return counts

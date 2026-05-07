"""Project-wide constants. No magic values anywhere else in the pipeline."""

from pathlib import Path

# File system
PROJECT_ROOT: Path = Path(__file__).resolve().parents[2]
CURATED_DIR: Path = PROJECT_ROOT / "data" / "curated"
CURATED_EVENTS_DIR: Path = CURATED_DIR / "events"
CURATED_LESSONS_DIR: Path = CURATED_DIR / "lessons"
OUTPUT_DIR: Path = PROJECT_ROOT / "data" / "output"
DEFAULT_DB_PATH: Path = OUTPUT_DIR / "thaqafa.db"

# Hijri calendar
HIJRI_MONTHS_COUNT: int = 12
HIJRI_MONTH_MID_DAY: int = 15  # anchor day for month-precision conversions
HIJRI_YEAR_MID_MONTH: int = 6  # anchor month for year-precision conversions
HIJRI_YEAR_MID_DAY: int = 15

# Gregorian calendar
GREGORIAN_MONTHS_COUNT: int = 12
GREGORIAN_DAYS_IN_LEAP_YEAR: int = 366

# Day-of-year keying
MD_KEY_MULTIPLIER: int = 31  # month*MD + day encodes Hijri mm-dd slot

# Wikidata SPARQL endpoint
WIKIDATA_SPARQL_ENDPOINT: str = "https://query.wikidata.org/sparql"
WIKIDATA_USER_AGENT: str = "thaqafa-pipeline/0.1 (research build; contact: trabelsisouhib@gmail.com)"
WIKIDATA_PERSONS_LIMIT: int = 5000
WIKIDATA_BATTLES_LIMIT: int = 2000
WIKIDATA_PRECISION_DAY: int = 11
WIKIDATA_PRECISION_MONTH: int = 10
WIKIDATA_PRECISION_YEAR: int = 9
WIKIDATA_HISTORICAL_CUTOFF_YEAR: int = 1800  # upper bound filter for ingest

# OpenITI metadata feed
OPENITI_META_URL: str = (
    "https://raw.githubusercontent.com/OpenITI/kitab-metadata-automation/"
    "master/output/OpenITI_Github_clone_all_author_meta.json"
)
OPENITI_HTTP_TIMEOUT: float = 60.0
OPENITI_MIN_HIJRI_YEAR: int = 1
OPENITI_MAX_HIJRI_YEAR: int = 1500

# Image safety policy
# Any Wikidata-imported person whose linked death event is before this
# Gregorian year is considered "early Islamic" and their person image is
# blocked as a precautionary measure.
EARLY_ISLAM_CUTOFF_YEAR: int = 900

# Hijri → Gregorian approximate conversion constant: Gregorian year ≈
# 622 + hijri_year * HIJRI_TO_GREGORIAN_RATIO (lunar vs solar year ratio)
HIJRI_EPOCH_GREGORIAN_YEAR: int = 622
HIJRI_TO_GREGORIAN_RATIO: float = 0.9703

# ---------------------------------------------------------------------------
# Content tables — the **only** tables the pipeline is allowed to drop.
# ---------------------------------------------------------------------------
#
# The dataset and the future user data share **one** SQLite/Postgres
# database. The pipeline rebuilds the dataset from YAML on every run; user
# data (accounts, bookmarks, preferences, …) is NOT touched. To keep that
# guarantee mechanical, ``init_db`` only drops the tables listed below —
# anything else (user_*, auth_*, etc.) is left alone, even if it somehow
# gets registered on ``SQLModel.metadata`` in the same process.
#
# Add a new content table here when you add it to ``pipeline.models.db``.
# Forgetting to add it means the pipeline won't drop it on rebuild —
# which is much better than the inverse (forgetting to register a user
# table here would silently wipe user data).
CONTENT_TABLE_NAMES: frozenset[str] = frozenset(
    {
        "sources",
        "people",
        "events",
        "date_claims",
        "event_people",
        "tags",
        "event_tags",
        "dateless_lessons",
        "observances",
        "images",
    }
)

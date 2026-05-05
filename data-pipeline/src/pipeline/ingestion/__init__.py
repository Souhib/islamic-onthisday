"""Ingestion sources. Each submodule exposes an ``ingest(session)`` function.

Only ``curated`` writes to the production SQLite — the bulk discovery
helpers (Wikidata, OpenITI) live under ``data-pipeline/scripts/discovery/``
and produce JSON reports the curator reviews by hand.
"""

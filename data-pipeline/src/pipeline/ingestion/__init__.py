"""Ingestion sources. Each exposes an `ingest(session)` function."""

from pipeline.ingestion import curated, openiti, wikidata

__all__ = ["curated", "openiti", "wikidata"]

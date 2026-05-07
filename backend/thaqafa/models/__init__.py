"""Backend-owned ORM tables.

Content tables (events, lessons, observances, people) are defined in the
``pipeline.models.db`` package and rebuilt from YAML on every pipeline
run. Backend-owned tables — accounts, bookmarks, anything user-generated —
live here so the pipeline's drop-and-recreate cycle never touches them.

Both packages register on the same global ``SQLModel.metadata``; the
pipeline's ``CONTENT_TABLE_NAMES`` allowlist filters drops to content
tables only, so user data is structurally protected from rebuilds.
"""

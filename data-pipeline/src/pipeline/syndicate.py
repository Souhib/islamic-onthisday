"""Alias module so ``python -m pipeline.syndicate`` works.

Defers to :mod:`pipeline.syndication` — the verb (``syndicate``) is the
natural CLI entry point, the noun (``syndication``) is where the logic
lives.
"""

from pipeline.syndication import main

if __name__ == "__main__":
    main()

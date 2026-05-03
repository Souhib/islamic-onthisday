"""Unit tests for the in-process TTL cache."""

import time

import pytest

from iotd.api.utils.cache import TTLCache


def test_cache_returns_value_until_ttl_elapses() -> None:
    cache = TTLCache(ttl_seconds=0.05)
    cache.set("k", "v")
    assert cache.get("k") == "v"
    time.sleep(0.06)
    assert cache.get("k") is None


def test_cache_per_call_ttl_overrides_default() -> None:
    cache = TTLCache(ttl_seconds=10)
    cache.set("short", "v", ttl_seconds=0.05)
    time.sleep(0.06)
    assert cache.get("short") is None


def test_cache_invalidate_drops_single_key() -> None:
    cache = TTLCache(ttl_seconds=10)
    cache.set("a", 1)
    cache.set("b", 2)
    cache.invalidate("a")
    assert cache.get("a") is None
    assert cache.get("b") == 2


def test_cache_invalidate_prefix_drops_a_family() -> None:
    cache = TTLCache(ttl_seconds=10)
    cache.set("today:2026-05-03", "x")
    cache.set("today:2026-05-02", "y")
    cache.set("recent:7", "z")
    cache.invalidate_prefix("today:")
    assert cache.get("today:2026-05-03") is None
    assert cache.get("today:2026-05-02") is None
    assert cache.get("recent:7") == "z"


def test_cache_clear_drops_everything() -> None:
    cache = TTLCache(ttl_seconds=10)
    cache.set("a", 1)
    cache.set("b", 2)
    cache.clear()
    assert cache.get("a") is None
    assert cache.get("b") is None


@pytest.mark.parametrize("missing_key", ["", "never-set", "today:9999-12-31"])
def test_cache_missing_key_returns_none(missing_key: str) -> None:
    cache = TTLCache(ttl_seconds=10)
    assert cache.get(missing_key) is None

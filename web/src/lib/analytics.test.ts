// Guards the no-op safety of the analytics module — the helper functions
// must never throw or call `window.umami.track` when the SDK isn't loaded.
// Catching this with a unit test means a contributor who reorganises the
// module won't accidentally make every page crash for users with an ad
// blocker.

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  trackDisputeOpened,
  trackEventView,
  trackLanguageChange,
  trackLessonView,
  trackObservanceView,
  trackPersonView,
} from "./analytics";

// `track` matches Umami's overloads loosely enough to satisfy the test.
// The cast keeps the suite isolated from the production type and lets us
// inspect arguments via `vi.fn`.
type FakeUmami = { umami?: { track: ReturnType<typeof vi.fn> } };
const win = window as unknown as FakeUmami;

describe("analytics — safe no-ops without umami", () => {
  beforeEach(() => {
    delete win.umami;
  });

  it("trackEventView does not throw when window.umami is missing", () => {
    expect(() => trackEventView("foo")).not.toThrow();
  });

  it("each domain helper is a silent no-op without umami", () => {
    expect(() => trackLessonView("x")).not.toThrow();
    expect(() => trackObservanceView("x")).not.toThrow();
    expect(() => trackPersonView("x")).not.toThrow();
    expect(() => trackLanguageChange("ar")).not.toThrow();
    expect(() => trackDisputeOpened("x")).not.toThrow();
  });
});

describe("analytics — happy-path forwarding", () => {
  let track: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    track = vi.fn();
    win.umami = { track };
  });

  afterEach(() => {
    delete win.umami;
  });

  it("trackEventView forwards { slug } payload", () => {
    trackEventView("fall-of-granada");
    expect(track).toHaveBeenCalledWith("event_view", { slug: "fall-of-granada" });
  });

  it("trackDisputeOpened forwards { slug }", () => {
    trackDisputeOpened("battle-of-kosovo-i");
    expect(track).toHaveBeenCalledWith("dispute_opened", { slug: "battle-of-kosovo-i" });
  });

  it("trackLanguageChange forwards { language }", () => {
    trackLanguageChange("fr");
    expect(track).toHaveBeenCalledWith("language_change", { language: "fr" });
  });
});

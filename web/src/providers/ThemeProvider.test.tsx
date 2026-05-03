import { render, screen } from "@testing-library/react";
import { act } from "react";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { ThemeProvider, useTheme } from "./ThemeProvider";

function TestProbe() {
  const { theme, toggle } = useTheme();
  return (
    <button type="button" onClick={toggle} data-testid="probe">
      {theme}
    </button>
  );
}

describe("ThemeProvider", () => {
  beforeEach(() => {
    window.localStorage.clear();
    document.documentElement.classList.remove("dark");
    delete document.documentElement.dataset.theme;
  });

  afterEach(() => {
    document.documentElement.classList.remove("dark");
  });

  it("initialises to 'light' when localStorage and matchMedia have no preference", () => {
    render(
      <ThemeProvider>
        <TestProbe />
      </ThemeProvider>,
    );
    expect(screen.getByTestId("probe").textContent).toBe("light");
    expect(document.documentElement.classList.contains("dark")).toBe(false);
  });

  it("reads a stored 'dark' preference from localStorage", () => {
    window.localStorage.setItem("iotd-theme", "dark");
    render(
      <ThemeProvider>
        <TestProbe />
      </ThemeProvider>,
    );
    expect(screen.getByTestId("probe").textContent).toBe("dark");
    expect(document.documentElement.classList.contains("dark")).toBe(true);
  });

  it("toggles flip the html.classList and persist to localStorage", () => {
    render(
      <ThemeProvider>
        <TestProbe />
      </ThemeProvider>,
    );
    const probe = screen.getByTestId("probe");
    expect(probe.textContent).toBe("light");

    act(() => probe.click());
    expect(probe.textContent).toBe("dark");
    expect(document.documentElement.classList.contains("dark")).toBe(true);
    expect(window.localStorage.getItem("iotd-theme")).toBe("dark");

    act(() => probe.click());
    expect(probe.textContent).toBe("light");
    expect(document.documentElement.classList.contains("dark")).toBe(false);
  });
});

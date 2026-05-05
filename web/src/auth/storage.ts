// Persistence for the auth session.
//
// Refresh token: stored in localStorage so the user stays signed in across
// tabs and reloads. Access token: held only in memory by the AuthProvider —
// kept off disk on purpose, so a leaked localStorage payload can't be
// replayed indefinitely. The trade-off: a hard refresh transparently
// trades the refresh token for a fresh pair via /api/v1/auth/refresh.

const REFRESH_TOKEN_KEY = "iotd.refresh_token";

export function readStoredRefreshToken(): string | null {
  try {
    return window.localStorage.getItem(REFRESH_TOKEN_KEY);
  } catch {
    return null;
  }
}

export function writeStoredRefreshToken(token: string | null): void {
  try {
    if (token === null) {
      window.localStorage.removeItem(REFRESH_TOKEN_KEY);
    } else {
      window.localStorage.setItem(REFRESH_TOKEN_KEY, token);
    }
  } catch {
    // localStorage can fail in private mode / SSR — fall back silently.
  }
}

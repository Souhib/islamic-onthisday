# Store Listing — Reference Sheet

Inputs to copy into the App Store Connect / Play Console submission
flows. Keep in sync with `ios/Runner/PrivacyInfo.xcprivacy` (the iOS
declaration) and `web/public/privacy.html` (the user-facing legal
copy) — those three sources have to agree.

## Identity

- App name: **Islamic On This Day**
- Short tagline: *One verified day in Islamic history, every day.*
- Bundle ID / applicationId: `app.iotd.iotd_mobile`
- Version: `1.0.0` (build `1`)
- Category: *Reference* (primary), *Education* (secondary)
- Rating: 4+ / Everyone
- Languages: English, French, Arabic
- Support URL: <https://news.majlisna.app/>
- Privacy URL: <https://news.majlisna.app/privacy.html>
- Terms URL: <https://news.majlisna.app/terms.html>

## Description (≤4000 chars — paste into both stores)

> Islamic On This Day delivers one verified historical event from Islamic
> history every day, in both Hijri and Gregorian calendars. Every entry
> is hand-vetted against classical Sunni sources (al-Ṭabarī, Ibn Kathīr,
> the Six Books) and carries its citations openly so you can verify what
> you read.
>
> A daily ritual, not a feed. The app shows today's event — no infinite
> scroll, no algorithmic noise, no ads. Read it once a day, set a quiet
> reminder for whatever hour fits your routine, and let the calendar
> bring you back tomorrow.
>
> Features:
> • One curated event per day (Hijri + Gregorian dates)
> • Bilingual / trilingual content (English, French, Arabic)
> • Verified hadith citations linked to sunnah.com; Qur'anic references
>   linked to quran.com
> • Disputed dates surfaced openly with classical alternative positions
> • Bookmark events to revisit
> • Optional daily reminder at the time of your choice
> • Home-screen widget (Android) — today's event at a glance
> • Works offline once content is cached
> • No tracking, no ads, no profiling
>
> Editorial bar: only events confirmed by classical Sunni sources. Only
> ṣaḥīḥ hadith. Drop entries we can't verify rather than guess. The
> dataset is open and the methodology is documented at
> news.majlisna.app.

## Google Play — Data Safety form

Copy these answers verbatim into the Play Console *Data safety* section.

### Data collection & sharing — overview

- **Does your app collect or share any of the required user data
  types?** → Yes
- **Is all of the user data collected by your app encrypted in
  transit?** → Yes (HTTPS / TLS 1.2+ for every API call)
- **Do you provide a way for users to request that their data be
  deleted?** → Yes — in-app *Settings → Account → Delete account*,
  cascades all bookmarks and tokens; same option in the web
  account page.

### Data types collected

For every type below: **Collected: Yes**, **Shared: No**, **Processed
ephemerally: No**, **Optional: Yes** (only when the user creates an
account).

| Category | Type | Purpose | Required? |
|----------|------|---------|-----------|
| Personal info | Email address | Account management, password reset | Required to create an account; the app is fully usable signed-out |
| Personal info | Name | Account management (display name) | Required to create an account |
| App activity | App interactions (bookmark events) | App functionality (sync bookmarks across devices) | Optional; only when signed in |
| App info & performance | Crash logs | App functionality (debugging crashes) | — |
| App info & performance | Diagnostics | App functionality (performance monitoring) | — |

### Data types **not** collected

Tick "No" for: Location, Financial info, Health & fitness, Messages,
Photos & videos, Audio files, Files & docs, Calendar, Contacts, Web
browsing, Search history, Installed apps, Other user-generated
content, Device or other IDs, **all advertising data**.

### Security practices

- Data is encrypted in transit. → **Yes**
- Users can request data deletion. → **Yes** (in-app + via the web)
- Independent security review. → **No** (truthful as of submission)
- Committed to Play Families Policy. → **N/A** (rating 4+)

### Third parties (sharing)

The app does **not** share any user data with third parties. Crash and
performance telemetry goes to our own Sentry instance which we operate
ourselves; it is not "sharing" in the Play Data Safety sense (same
data-controller).

If you keep the default Sentry SaaS endpoint (sentry.io) instead of
self-hosting, declare a single sharing entry:
- *Crash logs* → shared with Sentry → for app functionality.

## Apple App Store — privacy nutrition label

Mirrors `ios/Runner/PrivacyInfo.xcprivacy`. In App Store Connect the
form is shaped slightly differently from Play; here is the mapping.

### Data Used to Track You — **None**

We do not track users across apps or websites owned by other companies.
`NSPrivacyTracking = false` in the manifest.

### Data Linked to You

- **Contact Info → Email Address** (purpose: App Functionality)
- **Contact Info → Name** (purpose: App Functionality)

### Data Not Linked to You

- **Diagnostics → Crash Data** (purpose: App Functionality)
- **Diagnostics → Performance Data** (purpose: App Functionality)

### Required-reason API declarations

Already encoded in `PrivacyInfo.xcprivacy`:

- `NSPrivacyAccessedAPICategoryUserDefaults` → reason `CA92.1` (read +
  write app-defaults the user explicitly set: locale, notif time, theme).
- `NSPrivacyAccessedAPICategoryFileTimestamp` → `C617.1` (display files
  to the user — used by the dio cache for offline reads).
- `NSPrivacyAccessedAPICategoryDiskSpace` → `E174.1` (write user-
  generated content to disk — used by the cache eviction strategy).
- `NSPrivacyAccessedAPICategorySystemBootTime` → `35F9.1` (measure time
  on-device — used internally by Sentry's tracer when SENTRY_DSN is set).

## Screenshots

iOS sizes required:
- 6.7″ (iPhone 16 Pro Max): 1290 × 2796
- 6.5″ (iPhone 11 Pro Max): 1242 × 2688 (or 1284 × 2778)
- 5.5″ (iPhone 8 Plus): 1242 × 2208
- 12.9″ iPad Pro: 2048 × 2732

Android: at least 2 phone screenshots, optimal 8 (portrait,
1080 × 1920+).

Suggested shots (in order, both platforms):
1. Today screen — the headline event
2. Detail screen — the long-form reading with sources
3. Calendar / recent days
4. Bookmarks screen (signed-in)
5. Disputed-dates drawer (the editorial trust signal)
6. Settings — language, notifications, theme

Capture from a clean simulator: iPhone 16 Pro (6.7″) and Pixel 8
(1080 × 2400). Use the FR locale for the headline shot to make the
Arabic + French + English coverage obvious.

## Support / contact

- Support email: <support@news.majlisna.app> (set up an alias on the
  domain before submission — Apple verifies).
- Marketing URL: <https://news.majlisna.app/>

# Mobile release guide — App Store + Play Store

End-to-end checklist to ship `Islamic On This Day` to both stores.
The repo already carries everything we can prepare without your dev
accounts: app icon, privacy manifest, account-deletion flow, GlitchTip
wiring, signed-build scaffolding, store-listing copy in
[`STORE_LISTING.md`](./STORE_LISTING.md). What's left is the part that
needs your identity and your signing material.

Pair this file with `STORE_LISTING.md` (the metadata reference sheet)
and `ios/Runner/PrivacyInfo.xcprivacy` (the iOS privacy declaration).
All three must stay in sync.

## 0 — One-time accounts

| | Cost | Where |
|---|---|---|
| Apple Developer Program | $99 / year | <https://developer.apple.com/programs/enroll/> |
| Google Play Console | $25 one-shot | <https://play.google.com/console/signup> |

Apple's enrollment can take 1–7 days (identity verification). Start it
now even if the rest of the work isn't finished.

## 1 — Android signing key (one-time)

The keystore is what proves to Play Store that future updates come from
the same publisher. Lose it and you lose the ability to update the app.
Back it up to 1Password / iCloud Keychain / encrypted drive.

```sh
cd mobile/android
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Fill the prompts (use a strong password — it's never typed by hand
again). Then create `mobile/android/key.properties` from the example
template:

```sh
cp key.properties.example key.properties
# fill storePassword + keyPassword
```

Both `upload-keystore.jks` and `key.properties` are gitignored. Verify:

```sh
git status mobile/android/
# nothing should show up
```

The `build.gradle.kts` already reads `key.properties` and switches to
the release keystore when it exists; falls back to debug keys when it
doesn't.

## 2 — Apple Developer setup (one-time)

In <https://developer.apple.com/account>:

1. **Identifiers → +** → App IDs → App. Description: `Islamic On This
   Day`. Bundle ID: `app.iotd.iotdMobile` (must match
   `ios/Runner/Info.plist`'s `PRODUCT_BUNDLE_IDENTIFIER`). Capabilities:
   `Push Notifications` (off — we use local only), `App Groups` (off
   for now).
2. **Certificates → +** → Apple Distribution. Generate a CSR via
   Keychain Access → Certificate Assistant → Request a Certificate
   from a Certificate Authority. Upload, download the `.cer`, double-
   click to install.
3. **Profiles → +** → App Store. Pick the App ID + Distribution cert,
   download, double-click.
4. Note your **Team ID** (top-right of the Developer site or
   Membership tab) — you'll paste it into `ios/ExportOptions.plist`.

Update `ios/ExportOptions.plist`:

```xml
<key>teamID</key>
<string>ABCDE12345</string>     <!-- your Team ID -->
```

## 3 — App Store Connect listing (one-time per app)

In <https://appstoreconnect.apple.com>:

1. **My Apps → +** → New App.
   - Platform: iOS
   - Name: `Islamic On This Day`
   - Primary language: English (UK)
   - Bundle ID: pick the one created in step 2
   - SKU: `iotd-1` (any unique string)
2. **App Information** tab — fill from `STORE_LISTING.md`:
   subtitle, primary category (Reference), secondary (Education),
   age rating (4+), content rights checkbox.
3. **App Privacy** — fill the privacy nutrition label using the
   *Apple App Store — privacy nutrition label* section in
   `STORE_LISTING.md`. The form mirrors `PrivacyInfo.xcprivacy`:
   - Tracking: No
   - Data Linked to You: Email + Name (App Functionality)
   - Data Not Linked to You: Crash data + Performance (App Functionality)
4. **Pricing and Availability** — Free, all territories.
5. **Version 1.0 → "+ Add Localization"** (FR + AR if you want
   localized listings; the description from `STORE_LISTING.md`
   covers EN, translate for FR/AR or duplicate EN).

## 4 — Google Play Console listing (one-time per app)

In <https://play.google.com/console>:

1. **Create app** → name `Islamic On This Day`, default language
   English (UK), free, declarations checked.
2. **Set up your app** dashboard — six required tasks:
   - **App access**: All features available without restrictions.
   - **Ads**: No.
   - **Content rating**: complete the questionnaire (Reference / Books
     section, no objectionable content → Everyone).
   - **Target audience**: 13+ (or 18+ — pick what you're comfortable
     with; we don't target kids).
   - **News app**: No (Reference).
   - **Data safety**: copy answers verbatim from the *Google Play —
     Data Safety form* section in `STORE_LISTING.md`.
3. **Main store listing**:
   - Short description (80 chars): from `STORE_LISTING.md`
   - Full description (4000 chars): from `STORE_LISTING.md`
   - App icon: `mobile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` upscaled to 512×512 (or regenerate with `rsvg-convert -w 512 -h 512 /tmp/iotd-icon/icon.svg`)
   - Feature graphic: 1024×500, generate from the existing brand mark
     (cream paper + khātam centered + small wordmark at bottom).
   - Screenshots: see step 5.

## 5 — Screenshots

Apple requires:
- **iPhone 6.7"** (1290 × 2796): mandatory, 3–10 shots
- **iPad 12.9"** (2048 × 2732): mandatory if you support iPad

Google Play requires:
- **Phone** (≥1080 × 1920): mandatory, 2–8 shots
- **7" tablet** + **10" tablet**: optional but recommended

Capture from a clean simulator on the right device. From the project:

```sh
# iOS — boot the largest iPhone simulator
xcrun simctl boot "iPhone 17 Pro Max"   # or "iPhone 16 Pro Max"
open -a Simulator
cd mobile && flutter run -d booted

# inside the running app, navigate to each shot, then in another shell:
mkdir -p screenshots/ios-6.7
xcrun simctl io booted screenshot screenshots/ios-6.7/01-today.png
# ... repeat per screen
```

Suggested 6 shots (in order):
1. **Today** — the headline event
2. **Detail** — long-form reading
3. **Recent** — calendar of past days
4. **Bookmarks** — signed-in only
5. **Disputed-dates drawer** — opens the dispute footnote
6. **Settings** — language / theme / notification time

For the FR locale headline shot, set the device language to French
in Simulator → Settings → General → Language & Region.

## 6 — Production builds

The project's Sentry / GlitchTip DSN is hardcoded in `Makefile` so the
release builds bake it in. Override `MOBILE_SENTRY_ENV` when shipping
a beta to a different GlitchTip env.

### iOS

```sh
make mobile-release-ios
# Produces mobile/build/ios/ipa/iotd_mobile.ipa
```

Upload via **Transporter.app** (free, App Store) or `xcrun altool`:

```sh
xcrun altool --upload-app --type ios \
  --file mobile/build/ios/ipa/iotd_mobile.ipa \
  --apiKey <your_api_key> --apiIssuer <your_issuer_id>
```

The build appears in **TestFlight → iOS** within ~10 minutes. Test on
a real device first (TestFlight install), then submit for review from
App Store Connect → Version → Build → "Add to TestFlight" or "Submit
for Review".

### Android

```sh
make mobile-release-android
# Produces mobile/build/app/outputs/bundle/release/app-release.aab
```

Upload via Play Console → Internal Testing → "Create new release" →
upload the `.aab`. Test with the internal testing list first
(invite your own email), then promote to Production.

## 7 — Apple-specific gates

Things Apple specifically checks:

| Gate | Status |
|---|---|
| Privacy manifest (`PrivacyInfo.xcprivacy`) | ✅ shipped |
| Account deletion in-app | ✅ Settings → Account → Delete account |
| Privacy URL | ✅ `https://news.majlisna.app/privacy.html` |
| Support URL | ✅ `https://news.majlisna.app/` (set up `support@news.majlisna.app` alias before submission — Apple emails it) |
| App tracking transparency | N/A — `NSPrivacyTracking = false` |
| Sign in with Apple | N/A — we don't use third-party social login |
| In-app purchases | N/A — free, no IAPs |
| Sensitive permissions | None — local notifications only, no `NSUsageDescription` strings needed |

## 8 — Google-specific gates

| Gate | Status |
|---|---|
| Data Safety form | ✅ drafted in `STORE_LISTING.md` |
| Target API 34 (Android 14) | ✅ resolves via `flutter.targetSdkVersion` |
| 64-bit support | ✅ Flutter ships arm64 + x86_64 |
| Privacy Policy URL | ✅ |
| Account deletion (Play policy 2024) | ✅ in-app + web |
| Data deletion URL | use the `/account` page on the web — tell Play console: `https://news.majlisna.app/account` |
| `SCHEDULE_EXACT_ALARM` policy | ✅ stripped from manifest — we use inexact scheduling |

## 9 — Submission

iOS:
1. App Store Connect → your app → "+ Version" → 1.0
2. Pick the build (uploaded from step 6)
3. Tap "Submit for Review"
4. Apple reviews in 24–72h typically; longer if a reviewer flags
   anything

Google Play:
1. Production → "Create new release" → pick the AAB from step 6
2. Release notes (English first, then FR/AR)
3. "Review release" → "Send X for review"
4. Google reviews in a few hours to a few days

## 10 — Post-launch

- Verify GlitchTip starts receiving real-user crashes (filter
  `iotd-mobile` project on prod environment)
- Set up an Uptime Kuma monitor for the App Store / Play Store
  listing URLs to be alerted if either gets pulled
- The next build is just `make mobile-release-{ios,android}` →
  bump `pubspec.yaml`'s `version: 1.0.1+2` first → upload → submit
- For App Store, the version `1.0.1+2` becomes
  `CFBundleShortVersionString=1.0.1` and `CFBundleVersion=2`
- Increment `+N` on every upload even if the marketing version stays
  the same (App Store rejects duplicate build numbers)

## Common pitfalls

- **Apple bundle ID can't have underscores** — `app.iotd.iotd_mobile`
  is the Android applicationId, but iOS is `app.iotd.iotdMobile` (no
  underscore). The mismatch is intentional and unavoidable.
- **First TestFlight build sometimes appears as "Processing" for 30+
  minutes** — wait it out before assuming the upload failed.
- **Apple rejects on first submission for** missing screenshots /
  account-deletion explanation / privacy mismatch. Rare for us — all
  three are addressed.
- **Play Console rejects on** SCHEDULE_EXACT_ALARM (we strip it),
  POST_NOTIFICATIONS without justification (we declare it for daily
  reminders + the in-app permission flow), and target API < 34. None
  of those apply here.
- **Lost keystore = lost app** on Play Store. Back it up before
  uploading the first AAB.

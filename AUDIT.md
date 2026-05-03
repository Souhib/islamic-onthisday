# Dataset Audit — v1.1

A snapshot of the dataset audit at the point of "ready to start the app." Lists what has been reviewed, what has been fixed, and what still needs human verification before launch.

## Final dataset state

| Metric | Value |
| --- | ---: |
| Total events | 4,989 |
| Curated verified events | 172 |
| `verification_status` distribution | unverified 4,817 / single_source 79 / cross_verified 93 / scholar_reviewed 0 |
| `importance` distribution | minor 4,477 / notable 469 / major 50 |
| Day-precision verified curated | 99 |
| Dateless lessons | 146 |
| Annual observances | 12 |
| Reference validator | **All 24 Qur'an refs + 45 hadith refs well-formed** |
| Image-policy violations | 0 |

## Calendar standardisation

- All Gregorian dates are **proleptic Gregorian** (matches Wikidata, ISO 8601, astronomical software).
- A `julian_date` field is available on `Event` for pre-1582 events that need to display the historically-recorded date.
- The Hijri-to-Gregorian conversion path (`convertdate.islamic.to_gregorian`) returns proleptic Gregorian; results are flagged `method: tabular_conversion`.

## Schema improvements applied (v1.0 → v1.1)

- Added `display_hijri_month` and `display_gregorian_month` for month-primary daily rotation.
- Added `verification_status` field to capture review state.
- Added `julian_date` for pre-1582 historical-date display.
- Day-anniversary indices (`display_*_doy`) populated only when day is genuinely attested — never auto-faked from month precision.
- Wikidata + OpenITI imports tagged `verification_status: unverified`.
- Curated events default to `single_source` (1 claim) or `cross_verified` (≥2 claims).

## Editorial corrections applied

| Slug | Fix |
| --- | --- |
| `hijra-arrival-medina` | Title and description corrected: 12 Rabi' al-Awwal is the **entry into Madinah** after four days at Quba (8 Rabi' al-Awwal arrival at Quba). Added `Bukhari 3906` as cross-verifying citation. Promoted to `cross_verified`. |
| `death-of-fatima-az-zahra` | Switched from day-precise (3 Ramadan 11 AH) to **month-precise (Jumada al-Akhirah 11 AH)** since Sunni sources genuinely disagree (3 Jumada al-Akhirah / 14 Jumada al-Akhirah / 3 Ramadan / 8 Ramadan). All major positions now in `claims`. `disputed: true`, `cross_verified`. |
| `mawlid` (observance) | Demoted to `importance: notable`. Description now explicitly notes the Sunni dispute on (1) the day (8/9/10/12 Rabi' al-Awwal), and (2) the permissibility of communal celebration (al-Suyuti vs Ibn Baz/al-Albani). |
| `dhat-al-riqa` | `hadith_refs` corrected from invalid range "Bukhari 942-945" to single citation "Bukhari 942". |

## What I (Claude) was able to verify

- **Schema integrity** — every event has the required fields; every FK resolves.
- **Reference validity** — every `quran_refs` value points to a real surah:ayah pair; every `hadith_refs` value follows the well-formed `Collection N` pattern. Caught and fixed 1 malformed citation. Run `uv run python -m pipeline.validate` to re-verify.
- **Image policy enforcement** — 0 violations. Every Prophet/Sahabi/Ahl al-Bayt person record has `image_url=null`.
- **Date consistency within sources** — every `claims` entry's date matches the precision it declares.
- **YAML parsability** — every curated YAML file loads without errors.
- **Idempotency** — full pipeline rebuild produces identical output run-to-run (modulo Wikidata's evolving knowledge graph).

## What still requires human review

These are things I cannot do for you. Marking them here so they don't get lost.

### Highest priority — before public launch

1. **Sample-audit by a qualified Muslim reviewer.** Even 20-30 events spot-checked by a person with formal Islamic studies grounding (your local imam, a brother who has studied at al-Azhar / IIUM / Madinah / Umm al-Qura, or a trusted scholar online) tells us if the systematic quality is okay. Aim for diversity: 5 from Prophetic era, 5 from Rashidun, 5 from later dynasties, 5 women's entries, 5 lessons. Maybe 2 hours of their time.

2. **Hadith number deep verification.** The structural validator confirms `Bukhari 660` is well-formed; it does NOT confirm that hadith 660 in Bukhari says what we describe. Cross-check 30-50 hadith references against sunnah.com directly. Alternatively, mirror `AhmedBaset/hadith-json` locally and write a pipeline step to compare every cited hadith's first 100 chars against the description's quote. (Possible follow-up engineering: ~4 hours.)

3. **Disputed-flag completeness.** The Battle of the Trench (Shawwal vs Dhu al-Qa'da 5 AH), the birth date of the Prophet ﷺ (currently only as the Mawlid observance — not as an event), and any `verification_status: single_source` event should be reviewed for whether `disputed` should be set.

### Medium priority — post-launch but soon

4. **Quran ayah text storage.** Pull a public-domain Qur'an into a local `quran_ayat` table so the app can render verses without depending on quran.com. The Tanzil project distributes the standard Hafs Uthmani text under a clear license. ~1-2 hours.

5. **Hadith text storage.** Similar — mirror Sahih Bukhari + Muslim from `AhmedBaset/hadith-json` (MIT-licensed) into a `hadith_texts` table. Makes the app fully offline-capable for cited hadith. ~2 hours.

6. **Geographic coordinates** (`Event.lat`, `Event.lng`, `Event.place_name`). Pull from Wikidata `P276` (location) for events that have a geographic anchor. Karbala, Badr, Uhud, Granada, Constantinople — all have coordinates available. ~2 hours.

7. **Arabic translations** of curated event titles and descriptions. The schema already has `title_ar` / `description_ar` fields; most are empty. A scholar-translator pass would improve the dataset's value for Arabic-speaking users.

### Low priority — nice to have

8. **Image alternatives table** — multiple safe images per event so the app can pick. Currently most events have no image_url at all.

9. **Tag taxonomy normalisation** — current `tags` are free-form strings. Standardise into a controlled vocabulary.

10. **Event ↔ event relationships** — parent/child for compound events (Karbala → individual martyr deaths), causation chains.

## How the app should consume this dataset

To preserve accuracy guarantees:

1. **Display source citations on tap/click.** Every shown date or fact should be one click from "according to al-Tabari / Sahih al-Bukhari 660 / Wikidata Q…". The `claims` table is the basis.

2. **Default daily content rotates from the current Hijri month's pool.** Month is the safe primary index — eliminates ±3-day calendar errors. A typical rotation pool is 100-160 events per Hijri month.

3. **Day-anniversary callout when present.** If today's `(hijri_month, hijri_day)` matches a day-attested event (`display_hijri_md_key IS NOT NULL`), surface that as the headline. About 33 events qualify for the highest-prestige slot (`importance == 'major' AND display_hijri_md_key IS NOT NULL`).

4. **Show `disputed: true` events with a "scholarly views differ" affordance** — never present the canonical date as if it's the only one. The `claims` array is the data behind the disclosure.

5. **Honor `importance`** — major events get the headline, notable events get secondary rails, minor events (auto-imports) appear only when nothing higher-tier is available for the day.

6. **Honor `verification_status`** — show a subtle quality badge ("verified by 2 classical sources", "from Wikidata, not yet manually verified") so users can calibrate trust.

7. **Image policy is non-negotiable.** Even if the schema accidentally allows a Sahabi's image, the app must enforce a runtime check: `if person.is_prophet or person.is_sahabi or person.is_ahl_al_bayt: image_url = None`. Defense in depth.

## Re-running the audit

Any contributor can re-run all checks:

```sh
cd data-pipeline
uv run poe check                            # ruff lint + format
uv run python -m pipeline.build             # rebuild DB
uv run python -m pipeline.validate          # check refs
```

The DB is regenerated from YAML + live Wikidata + live OpenITI on every run; nothing is hand-edited in the SQLite file.

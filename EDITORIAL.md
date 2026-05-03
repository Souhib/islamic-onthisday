# Editorial Standards

The bar for adding or modifying any content in this dataset. Every contributor — human or AI agent — must hold to it.

## Non-negotiable rules

1. **No fabricated precision.** If classical sources record only the year, store only the year. If only the month, only the month. Never invent a day to make the calendar nicer.

2. **No depiction of restricted figures.** No image — drawn, painted, photographed, statue, calligraphic figure, or otherwise — of:
   - Any prophet (Anbiya')
   - Any Sahabi (Companion)
   - Any member of Ahl al-Bayt
   This is a hard policy enforced in the image fetcher. It is not subject to override.

3. **Every claim has a source citation.** Every `Event.claims` entry references a `Source` row by key. Every `Event.hadith_refs` and `Event.quran_refs` is structurally validated by `pipeline.validate`. Free-text descriptions that make a factual claim (e.g. "narrated in", "tradition records") must point to the sahih hadith via `hadith_refs` or to the Qur'an via `quran_refs`.

4. **Disputes are data, not editorial.** When classical Sunni sources disagree on a date or fact, model the disagreement as multiple `claims` and set `disputed: true`. Do NOT pick one and silence the others. Examples already modelled this way: death of the Prophet ﷺ, death of Fatima ra, Battle of Uhud day, al-Hallaj's status.

   **Hard invariant — `disputed: true` requires `verification_status >= cross_verified`.** The disputed flag means *the date or a small detail is contested* — the event itself must already be confirmed by ≥2 independent classical Sunni sources. A `single_source` or `unverified` event with `disputed: true` is a contradiction: if you don't even know the event happened, "the dispute" is meaningless. To mark an event disputed: either find a second classical source and promote to `cross_verified` first, drop the disputed flag, or remove the event entirely. Enforced by `pipeline.validate` (CI-blocking).

5. **Sectarian scope is Sunni tradition.** Sources, claims, and editorial framing draw from the Sunni canon (Qur'an, Six Books of hadith, classical Sunni mufassirin / muhaddithin / fuqaha'). Karbala, Ahl al-Bayt, the Rashidun caliphs are shared heritage and stay; Shia-doctrinal-specific content (e.g. the twelve Shia imams as imams) is out of scope.

6. **Trilingual content (en / ar / fr).** Every event, dateless lesson, and observance carries:
   - `title_en` + `title_ar` + `title_fr` (or `name_*` for observances)
   - `description_en` + `description_ar` + `description_fr`
   English is the source of truth; Arabic and French translations follow it. Arabic uses Modern Standard Arabic, formal register, dignified scholarly tone, vocalised where it aids reading. French uses formal academic register: "le Prophète Muhammad ﷺ", "Coran", "compagnon (sahabi)", "califat", "hadith authentique", proper diacritics on names ("ʿAlī ibn Abī Ṭālib", "Sa'd al-Dīn al-Taftāzānī"), ﷺ after the Prophet's name, "ra" after Sahaba names. The frontend picks per user preference with a fallback chain (requested → en → first non-null) — but new entries should always ship trilingual.

7. **Bulk imports populate the catalogue, never the headline.** Wikidata SPARQL and OpenITI metadata ingestion is enabled in production builds with `pipeline.build --include-bulk`, which restores ~3,800 events to the dataset for browse / search depth. Two backend invariants protect headline quality:
   - **The headline (`/api/v1/today`)** only ever picks events with `importance ∈ {major, notable}` and `verification_status ∈ {single_source, cross_verified, scholar_reviewed}`. Bulk-imported events land at `importance: minor` and `verification_status: unverified`, so they are *structurally excluded* from the headline slot. When no curated event matches the day, the headline returns `None` and the front-end falls back to a dateless lesson — **never** an anonymous Wikidata "Death of …" entry.
   - **The frontend** prominently shows the `UNVERIFIED` badge on every bulk-import card in browse / search (warm-umber border + dot). Readers always see the trust level before clicking through.

   This means: a Wikidata-imported scholar can be promoted to headline-eligibility by writing a curated YAML entry for them and setting `verification_status: cross_verified` — the bulk import is the catalogue placeholder; the curated YAML is the editorial promotion. If you can't bring an entry up to the editorial bar in `EDITORIAL.md` rules 1–6, leave it as bulk — the user will still see it in browse with the honest badge.

8. **Sunni orthodoxy — the four-madhhab bar.** Every figure included as a scholar, Sufi shaykh, ruler, or muḥaddith must be defensible within Ahl al-Sunna wa-l-Jamāʿa as represented by the four mainstream fiqh schools (Ḥanafī, Mālikī, Shāfiʿī, Ḥanbalī), their accepted ʿaqīda (Ashʿarī, Māturīdī, Atharī), and the figures who anchored these principles before the formal codification of the schools (early Sahaba, Tābiʿūn, the early ascetic-zāhid tradition). The dataset is **conservative-Sunni** by design.

   **Default rule: drop the borderline entry.** Figures whose teachings or movements have been credibly accused by mainstream Sunni scholarship of *ghuluw* (excess in saint-veneration), of asserting prophetic-tier authority for a saint, of substituting the ṭarīqa's rituals for canonical Sunni obligations, or of theological positions that drew formal condemnation or execution within their lifetime — **are excluded even when they are politically, literarily, or culturally significant.** The dataset's value is the guarantee that what is in it is mainstream-Sunni-defensible. We prefer **fewer events than borderline ones**.

   ### Definitively excluded — by name
   - **Twelver Shia imāms-as-imāms.** ʿAlī ibn Abī Ṭālib ra, al-Ḥasan and al-Ḥusayn ra are sahaba / Ahl al-Bayt and stay (shared heritage). Imāms 4-12 (Zayn al-ʿĀbidīn, al-Bāqir, al-Ṣādiq, al-Kāẓim, al-Riḍā, al-Jawād, al-Hādī, al-ʿAskarī, al-Mahdī al-Muntaẓar) framed *as imāms in the Twelver doctrinal sense* are out of scope.
   - **Twelver Shia compilers / theologians as such**: al-Sharīf al-Raḍī (compiler of *Nahj al-Balāgha*), al-Sharīf al-Murtaḍā, al-Kulaynī, Ibn Bābawayh al-Ṣadūq, al-Mufīd, al-Ṭūsī al-imāmī, al-Majlisī etc.
   - **Ismāʿīlī imāms-as-imāms.** Fatimid caliphs are included as political-historical figures (their rule of Egypt is shared heritage); their imāmate claim is not endorsed.
   - **Druze, Nuṣayrī/ʿAlawī, Ahmadiyya/Qādiyānī, Bahāʾī, Bābī, Yazdānī.** All outside the Ahl al-Sunna fold by mainstream Sunni consensus.
   - **Khārijī, Ibāḍī, Zaydī as doctrinal figures.**
   - **Muʿtazilī figures framed doctrinally.** Wāṣil ibn ʿAṭāʾ, Abū al-Hudhayl al-ʿAllāf, al-Naẓẓām, ʿAmr ibn ʿUbayd. al-Zamakhsharī is the lone exception, included strictly for his philological contribution to *al-Kashshāf* (canonical in later Sunni tafsir despite his kalām).
   - **Mouride** (Aḥmadu Bamba) and **Tijani-Niassene fayḍa branch** (Ibrāhīm Niass) — quasi-prophetic veneration of the founder.
   - **Tijaniyya** (Aḥmad al-Tijānī, al-Ḥajj ʿUmar Tāl) — yaqẓa-vision-of-Prophet ﷺ claim teaching the Lazimu Ṣalāt al-Fātiḥ; equivalence-with-6000-Qurʾān-khatm claim; *khatm al-awliyāʾ* (seal of saints) claim. Removed 2026-04-29.
   - **Akbarian school** (Ibn ʿArabī's *waḥdat al-wujūd* current — Ṣadr al-Dīn al-Qūnawī, ʿAbd al-Karīm al-Jīlī, ʿAfīf al-Dīn al-Tilimsānī, Ibn Sabʿīn). Removed 2026-04-29.
   - **Aḥmad Sirhindī's *qayyūmiyya* claim** — Removed 2026-04-29.
   - **Executed-for-heresy figures** (al-Ḥallāj, ʿAyn al-Quḍāt al-Hamadhānī, Yaḥyā al-Suhrawardī al-Maqtūl) — removed even framed as historical-execution events; their inclusion conferred undue prestige. Removed 2026-04-29.
   - **Ibn al-Fāriḍ** (*Tāʾiyya al-Kubrā* contains waḥdat al-wujūd themes) — Removed 2026-04-29.
   - **al-Rifāʿī** (Rifāʿiyya body-piercing dhikr rituals critiqued by Ibn Taymiyya and by sober Sufi orders themselves) — Removed 2026-04-29.
   - **Aḥmad al-Ghazālī** (*Sawāniḥ ʿushshāq* love-mysticism that produced his executed disciple ʿAyn al-Quḍāt al-Hamadhānī) — Removed 2026-04-29.

   ### Inclusion-positive — clearly within scope
   - **Sahaba, Tābiʿūn, Tabiʿ al-Tābiʿīn**, the early ascetic-zāhid tradition (Ḥasan al-Baṣrī, Mālik ibn Dīnār, Ibrāhīm ibn Adham, Bāyazīd al-Bisṭāmī, etc.) before madhhab codification.
   - **The four madhhab founders** (Abū Ḥanīfa, Mālik, al-Shāfiʿī, Aḥmad ibn Ḥanbal) and their secondary scholars across all centuries.
   - **Mainstream Sunnī Sufi orders** firmly embedded in fiqh: Qādiriyya (ʿAbd al-Qādir al-Jīlānī), Naqshbandiyya (Bahāʾ al-Dīn Naqshband), Shādhiliyya (Abū al-Ḥasan al-Shādhilī, Ibn ʿAṭāʾ Allāh al-Iskandarī), Suhrawardiyya (ʿUmar al-Suhrawardī, Abū al-Najīb al-Suhrawardī), Chishtiyya (Muʿīn al-Dīn Chishtī, Niẓām al-Dīn Awliyāʾ), Kubrawiyya (Najm al-Dīn al-Kubrā), Mawlawiyya (Rūmī), Khalwatiyya, Yasawiyya (Aḥmad Yasawī), Badawiyya (Aḥmad al-Badawī), Dasūqiyya (Ibrāhīm al-Dasūqī).
   - **Sufi compilers of mainstream tradition**: al-Sulamī, al-Qushayrī, al-Hujwirī, Abū Nuʿaym al-Iṣfahānī, al-Sarrāj al-Ṭūsī, Abū Ṭālib al-Makkī, al-Kalābādhī, ʿAbd Allāh al-Anṣārī al-Harawī, al-Shaʿrānī, al-Niffārī.
   - **Ḥanbalī-Atharī revival figures** including Muḥammad ibn ʿAbd al-Wahhāb and the Saudi states, framed factually as Sunnī-Ḥanbalī reform rather than a separate sect.
   - **Modern Sunnī movements** (Deobandī, Tablīghī Jamāʿat, Ikhwān al-Muslimīn historical figures, Salafī, Azharī, Bā ʿAlawī sayyids of Hadhramaut) included with factual framing across the spectrum.

   ### Test
   When in doubt: read the figure's primary works (or what their disciples claim about them in their canonical literature) and ask whether a typical Ḥanafī, Mālikī, Shāfiʿī, or Ḥanbalī ʿālim of the past four centuries would defend the figure as within the Ahl al-Sunna fold without significant qualification. If not — **drop**.

## Event reality — 100% historicity required

Before adding any event, **the event itself must be a verified historical fact**, not the date. Two requirements:

1. **The event must be attested in ≥2 independent classical Sunni sources** (al-Ṭabarī, al-Dhahabī, Ibn Khallikān, Ibn Kathīr, Ibn Saʿd, Ibn al-Athīr, Ibn Ḥajar, the Six Books, etc.) for `cross_verified` status, or in 1 source for `single_source`.

2. **Never invent or speculate about an event.** If you cannot trace the event to a real classical or contemporary primary source, drop it. Wikipedia summaries alone are not sufficient — they may compress, distort, or report stub-level material.

**Date is secondary to event reality.** A real event with an uncertain date is acceptable. A speculative event with a precise date is not.

## Date uncertainty — protocol

When the date is not unambiguous in the classical sources, follow this protocol:

### A. Date attested in one source, confirmed by others
- Use the precision the source provides (year, month, or day).
- Cite both sources via `claims`.
- No `disputed` flag needed.

### B. Sources disagree on the date
- Use the **majority opinion** (the date most-cited across the canonical sources) as `canonical_hijri` / `canonical_gregorian`.
- Set `disputed: true` and `dispute_about: date`.
- In the `description_*`, **explicitly explain which source you're following and why**, plus mention the alternative dates from the other sources (e.g. "al-Ṭabarī gives 36 AH, Ibn Saʿd gives 38 AH; we follow al-Ṭabarī as the earlier and more directly attested authority").
- Add an additional `claims` row per alternative date so the dispute is data, not editorial silencing.

### C. Single uncertain source attesting a date
- Use `precision: year` only (do not refine to month/day from a weak attestation).
- Mention the limitation in the description body.
- Consider whether the event reaches the editorial bar at all.

### D. Truly no date attested, or dates too uncertain to commit to a year
- **Convert to a dateless `lesson` instead of an `event`.** Lessons sit in `data/curated/lessons/` and rotate through the calendar via `display_day_of_year` without anchoring to a specific Hijri/Gregorian moment.
- Use the `hadith_narrative`, `quran_story`, `quran_hadith_fact`, or `sunnah_practice` category as appropriate.
- This preserves the educational/historical value of the content without lying about the date.

## Hadith authentication — strict ṣaḥīḥ-only policy

All `hadith_refs` cited as authoritative must point to:

(a) **Ṣaḥīḥ al-Bukhārī or Ṣaḥīḥ Muslim** (sahih by consensus of the umma), OR

(b) **Non-Ṣaḥīḥayn collections** (al-Tirmidhī, Abū Dāwūd, al-Nasāʾī, Ibn Mājah, al-Dārimī) where the specific narration is graded **ṣaḥīḥ** by Darussalam, al-Albānī, or Shuʿayb al-Arnāʾūṭ.

**Ḥasan and ḍaʿīf citations are not permitted** in `hadith_refs`, even when the principle is corroborated through other narrations. Drop the citation rather than cite weakly. If the lesson or event content rests on a non-ṣaḥīḥ narration, either find a ṣaḥīḥ alternative or remove the entry. The `lessons/` corpus has been audited under this rule (2026-04-27): all hadith citations now point to grade-verified ṣaḥīḥ narrations.

Numbering follows the standard sunnah.com indexing. Before committing a new `hadith_refs`, verify the number on https://sunnah.com/<collection>:<n> and confirm the matn matches the description.

## Wikidata QIDs — verify or omit

Wikidata Q-numbers are **not trusted by default**. An audit of 289 person entries on 2026-04-26 found ~95 % systemic mismatch — Q-numbers hallucinated from training memory pointed to unrelated entities (museums, bird species, footballers). All QIDs were purged.

When adding a `wikidata_qid` to `people.yaml`:

1. Fetch via `https://www.wikidata.org/w/api.php?action=wbgetentities&ids=<QID>&props=labels|sitelinks&languages=en|ar&format=json`.
2. Confirm the English/Arabic label matches the declared name (allow common transliteration variations).
3. Confirm the Wikipedia article (en or ar) is about this person.
4. Only then commit the QID.

If verification fails or you are uncertain, omit the field — the dataset functions correctly without it.

## Verification tiers

Every `Event.verification_status` field is one of:

| Status | Meaning | Use for |
|---|---|---|
| `unverified` | Auto-import (Wikidata, OpenITI), no cross-reference | Transient — events sit here only until `pipeline.verify` runs |
| `auto_verified` | `pipeline.verify` cross-checked against Wikidata + Wikipedia | Bulk-imported events that survived structural verification (Wikipedia article exists, dates within ±10 Hijri years). Description is from Wikipedia summary; not yet hand-edited to the Sunni-framing bar. **Not headline-eligible.** |
| `single_source` | One classical Sunni citation, no cross-check | New curated event with one source |
| `cross_verified` | ≥2 independent classical Sunni sources confirm | New curated event backed by multiple sources |
| `scholar_reviewed` | A qualified Muslim scholar has signed off | Reserve for events that have undergone formal review |

Promotions go up the tier ladder; never demote without a corrected source.

## Adding a new event — checklist

Before opening a YAML edit:

- [ ] Identify the event in **at least one** classical Sunni source by name (e.g. *al-Tabari, Tarikh* vol. 5, p. 234; *Ibn Hisham, Sira*; *al-Dhahabi, Siyar A'lam al-Nubala'*; or one of the Six Books for hadith content).
- [ ] Determine the **highest precision the source actually attests** — not the highest precision you wish you had.
- [ ] Add a `claims` entry per source that confirms the event. Each claim quotes its precision honestly.
- [ ] Set `verification_status` based on claim count:
  - 1 source → `single_source`
  - ≥2 sources → `cross_verified`
- [ ] If the event involves a person who is a Prophet, Sahabi, or member of Ahl al-Bayt, ensure that person's record in `people.yaml` has `is_prophet/is_sahabi/is_ahl_al_bayt: true` so the image policy hard-block applies.
- [ ] Add `hadith_refs` and/or `quran_refs` for any specific hadith or verse cited in the description. The `pipeline.validate` script will catch malformed citations.
- [ ] Mark `disputed: true` if classical Sunni sources disagree on date or essential facts. Add the alternative date as an additional `claims` row.
- [ ] Run `uv run python -m pipeline.build --skip-wikidata --skip-openiti` to verify the YAML loads cleanly.
- [ ] Run `uv run python -m pipeline.validate` to confirm references are well-formed.

## Adding a new lesson — checklist

For dateless Qur'an stories, hadith narratives, Sunnah practices, or Qur'an/hadith facts:

- [ ] Cite the **exact** Qur'an passage (`reference: Surah al-Baqara 2:255`) AND populate `quran_refs: "2:255"` for structured access.
- [ ] For hadith narratives, cite by the standard Sunnah.com numbering — `Sahih al-Bukhari 660` style — and populate `hadith_refs: "Bukhari 660"`.
- [ ] For hadiths classified as weak (da'if) or fabricated (mawdu'), flag the grade explicitly in the description. Do not present a weak hadith as if sahih. The "I was a hidden treasure" lesson is the model — it is included specifically to teach the principle of isnad criticism.
- [ ] No content from sources outside the Sunni hadith canon framed as authoritative. Sufi narratives without sahih backing belong in their own clearly-labelled category (we don't currently include any).
- [ ] Pick a unique `display_day_of_year` 1-366 if you want the lesson to anchor on a specific day. Multiple lessons may share a day; the backend rotates by year.

## Promoting an event to `importance: major`

The `importance` field controls headline placement. To set `importance: major`:

- The event must be one a typical educated Muslim would recognise by name.
- Date must be either day-precise + verified, or month-precise + universally agreed.
- The event must already be `verified: true` and `verification_status: cross_verified` or higher.

The current canonical-majors list lives in `pipeline.build.CANONICAL_MAJOR_SLUGS`. Add a slug there to promote.

## Calendar conventions

- All `canonical_gregorian_date` values are **proleptic Gregorian** (matching Wikidata, ISO 8601, astronomical software).
- For pre-1582 events, `julian_date` may also be populated — this is the date most history books use. The two differ by 0-10 days depending on era (3 days for the 7th century, 10 days by 1500 CE).
- Hijri-to-Gregorian conversion uses the classical tabular algorithm via `convertdate.islamic`; the result is a proleptic Gregorian date, marked with `method: tabular_conversion`.
- When historical sources give an attested Gregorian date directly (e.g. "29 May 1453 for Constantinople"), use that and mark `method: attested`.

## Image conventions

- For events tied to a Prophet/Sahabi/Ahl al-Bayt person: image MUST be of a place, mosque, manuscript, calligraphy, or geographic location — never the person.
- For events tied to a later figure (post-900 CE), images are permitted but check that the source doesn't have a person depiction policy contradiction.
- Always store `image_attribution` and `image_license` alongside `image_url`.

## Editorial corrections — process

If a contributor finds an error in existing content:

1. Open the affected YAML and fix it.
2. If the fix changes a claim or canonical date, add the original (incorrect) claim's reasoning to a comment explaining why the previous version was incorrect.
3. If `disputed: true` was missing and now is needed, set it and add the alternative claim.
4. Run `uv run poe check` (ruff) and `uv run python -m pipeline.validate` (refs) before committing.
5. Run a full pipeline rebuild to verify nothing else regresses.

## What this dataset is not

- **Not a fatwa source.** Events and lessons present historical facts and authentic narrations; they do not deliver legal rulings. Users seeking legal guidance should consult a qualified Islamic scholar.
- **Not a complete Islamic encyclopedia.** It is "On This Day" — a curated calendar of historically-anchored content. Topics that don't fit the calendar form (theology, fiqh treatise content, biographical depth) belong elsewhere.
- **Not a substitute for primary sources.** Every claim should be verifiable in the cited classical source. The dataset is a navigation layer over the tradition, not a replacement for it.

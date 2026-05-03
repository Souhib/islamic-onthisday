# Validation report

**Quran refs checked:** 319  
**Hadith refs checked:** 506  
**Disputed events:** 84  
**Disputed-invariant violations:** 0  

| Kind | Records checked | With errors |
| ---- | ---: | ---: |
| Events | 68 | 0 |
| Lessons | 309 | 0 |
| Observances | 10 | 0 |

## Errors

**None — all references are well-formed.**

## Notes
- Reference validation is purely structural: surah/ayah ranges and collection-name format.
- It does NOT verify that the cited hadith says what we describe — that requires deep validation against sunnah.com or a local Sahih corpus mirror (e.g. AhmedBaset/hadith-json).
- Quran ayah-count table is the Kufan/Hafs count (114 surahs, 6,236 verses).
- Editorial invariant: any event with `disputed: true` must already be `verification_status >= cross_verified`.
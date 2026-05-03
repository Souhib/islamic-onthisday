# Lesson expansion topic list — 160 new DatelessLesson entries
# Generated 2026-04-29. Each entry maps to a unique display_day_of_year.
# Batches of 20; each batch written by a separate subagent.

# Missing days (223 total). We use 160 of them.
missing_days = [1, 2, 4, 5, 9, 14, 20, 23, 24, 34, 35, 44, 50, 54, 64, 65, 71, 74, 80, 81, 84, 86, 89, 90, 91, 94, 95, 99, 101, 104, 108, 109, 110, 111, 113, 114, 118, 119, 120, 121, 123, 124, 125, 128, 129, 131, 133, 134, 138, 139, 140, 141, 143, 144, 146, 148, 149, 150, 151, 153, 154, 155, 156, 158, 159, 161, 163, 164, 166, 168, 169, 170, 171, 173, 174, 178, 179, 180, 181, 183, 184, 185, 188, 189, 191, 193, 194, 198, 199, 200, 201, 203, 204, 208, 209, 210, 211, 213, 214, 215, 218, 219, 221, 223, 224, 227, 228, 229, 230, 231, 232, 233, 234, 237, 238, 239, 240, 241, 242, 243, 244, 245, 247, 248, 249, 251, 252, 253, 254, 257, 258, 259, 260, 261, 262, 263, 264, 267, 268, 269, 270, 271, 272, 273, 274, 275, 277, 278, 279, 281, 282, 283, 284, 285, 287, 288, 289, 290, 291, 292, 293, 294, 297, 298, 299, 300, 301, 302, 303, 304, 305, 307, 308, 309, 311, 312, 313, 314, 315, 317, 318, 319, 320, 321, 322, 323, 324, 327, 328, 329, 330, 331, 332, 333, 334, 335, 337, 338, 339, 341, 342, 343, 344, 345, 347, 348, 349, 350, 351, 352, 353, 354, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366]

# We need 160 days. Take every other day from the missing list to spread evenly.
selected_days = missing_days[::1][:160]  # first 160

# =============================================================================
# BATCH 1 — quran_story (lessons 1-20)
# =============================================================================
batch1 = [
    (1, "quran-story-nuh-and-the-ark", "quran_story", "The Story of Nuh ﷺ and the Ark — A Warning to the Arrogant", "Qur'an 71:1-28 (Surah Nuh)", "71:1-28, 11:36-49, 23:23-30"),
    (2, "quran-story-ibrahim-and-the-idols", "quran_story", "Ibrahim ﷺ Smashes the Idols — The Birth of Tawhid", "Qur'an 21:51-70 (Surah al-Anbiya)", "21:51-70, 37:83-98"),
    (4, "quran-story-lut-and-the-cities", "quran_story", "The Story of Lut ﷺ and the Destroyed Cities", "Qur'an 11:69-83 (Surah Hud)", "11:69-83, 15:51-77"),
    (5, "quran-story-yusuf-in-the-well", "quran_story", "Yusuf ﷺ Thrown into the Well — The Test of Brothers", "Qur'an 12:4-20 (Surah Yusuf)", "12:4-20"),
    (9, "quran-story-yusuf-in-egypt", "quran_story", "Yusuf ﷺ in Egypt — From Prison to Power", "Qur'an 12:21-57 (Surah Yusuf)", "12:21-57"),
    (14, "quran-story-yusuf-reunited", "quran_story", "Yusuf ﷺ Reunited with His Family — Forgiveness Above Vengeance", "Qur'an 12:58-101 (Surah Yusuf)", "12:58-101"),
    (20, "quran-story-shuaib-and-the-merchants", "quran_story", "The Story of Shu'ayb ﷺ and the Dishonest Merchants", "Qur'an 11:84-95 (Surah Hud)", "11:84-95, 7:85-93"),
    (23, "quran-story-musa-and-the-magicians", "quran_story", "Musa ﷺ and the Magicians of Pharaoh — Truth Overwhelms Falsehood", "Qur'an 7:103-126 (Surah al-A'raf)", "7:103-126, 20:56-73"),
    (24, "quran-story-musa-crossing-the-sea", "quran_story", "Musa ﷺ Crosses the Sea — When the Impossible Becomes a Path", "Qur'an 26:52-68 (Surah al-Shu'ara)", "26:52-68, 44:17-33"),
    (34, "quran-story-dawud-and-jalut", "quran_story", "Dawud ﷺ and Jalut — The Victory of Faith Over Strength", "Qur'an 2:249-251 (Surah al-Baqara)", "2:249-251"),
    (35, "quran-story-dawud-and-the-sheep", "quran_story", "Dawud ﷺ Judging Between Shepherds — Justice and Humility", "Qur'an 21:78-82 (Surah al-Anbiya)", "21:78-82, 38:17-26"),
    (44, "quran-story-sulayman-and-the-hoopoe", "quran_story", "Sulayman ﷺ and the Hoopoe — Knowledge from Unexpected Sources", "Qur'an 27:15-44 (Surah al-Naml)", "27:15-44"),
    (50, "quran-story-sulayman-and-bilqis", "quran_story", "Sulayman ﷺ and Bilqis — The Queen Who Submitted", "Qur'an 27:22-44 (Surah al-Naml)", "27:22-44"),
    (54, "quran-story-ayyub-and-his-patience", "quran_story", "The Patience of Ayyub ﷺ — When Affliction Becomes a Proof", "Qur'an 21:83-84, 38:41-44 (Surah al-Anbiya / Sad)", "21:83-84, 38:41-44"),
    (64, "quran-story-yunus-in-the-whale", "quran_story", "Yunus ﷺ in the Belly of the Whale — The Du'a That Saved Him", "Qur'an 37:139-148 (Surah al-Saffat), 21:87-88", "37:139-148, 21:87-88"),
    (65, "quran-story-zakariyya-and-the-child", "quran_story", "Zakariyya ﷺ and the Birth of Yahya — Prayer in Old Age", "Qur'an 19:2-15 (Surah Maryam), 3:37-41, 21:89-90", "19:2-15, 3:37-41"),
    (71, "quran-story-maryam-and-the-palm-tree", "quran_story", "Maryam and the Palm Tree — The Birth of Isa ﷺ", "Qur'an 19:16-33 (Surah Maryam)", "19:16-33"),
    (74, "quran-story-isa-speaking-from-cradle", "quran_story", "Isa ﷺ Speaking from the Cradle — The Infant Prophet Defends His Mother", "Qur'an 19:30-33 (Surah Maryam), 3:46", "19:30-33, 3:46"),
    (80, "quran-story-ashab-al-kahf", "quran_story", "The People of the Cave — Youth Who Chose Faith Over Fear", "Qur'an 18:9-26 (Surah al-Kahf)", "18:9-26"),
    (81, "quran-story-ashab-al-kahf-and-the-dog", "quran_story", "The Dog of the People of the Cave — Even Animals in God's Protection", "Qur'an 18:18, 18:22 (Surah al-Kahf)", "18:18, 18:22"),
]

# =============================================================================
# BATCH 2 — quran_story continued (lessons 21-40)
# =============================================================================
batch2 = [
    (84, "quran-story-musa-and-al-khidr", "quran_story", "Musa ﷺ and al-Khidr — When Knowledge Surprises the Knowing", "Qur'an 18:60-82 (Surah al-Kahf)", "18:60-82"),
    (86, "quran-story-ibrahim-and-the-angel-of-death", "quran_story", "Ibrahim ﷺ and the Angel of Death — A Cheerful Welcome", "Qur'an 37:83-102 (Surah al-Saffat), 2:124-132", "37:83-102, 2:124-132"),
    (89, "quran-story-the-two-sons-of-adam", "quran_story", "The Two Sons of Adam — The First Murder and Its Lesson", "Qur'an 5:27-31 (Surah al-Ma'ida)", "5:27-31"),
    (90, "quran-story-the-people-of-sabt", "quran_story", "The People Who Broke the Sabbath — When Rules Become Tests", "Qur'an 2:65-66 (Surah al-Baqara), 7:163-166", "2:65-66, 7:163-166"),
    (91, "quran-story-the-owners-of-the-garden", "quran_story", "The Owners of the Garden — Greed and Its Consequence", "Qur'an 68:17-33 (Surah al-Qalam)", "68:17-33"),
    (94, "quran-story-the-people-of-thamud", "quran_story", "The People of Thamud — The She-Camel of Allah", "Qur'an 11:61-68 (Surah Hud), 26:141-159, 54:23-31", "11:61-68, 26:141-159, 54:23-31"),
    (95, "quran-story-the-people-of-ad", "quran_story", "The People of Ad — The Wind That Destroyed", "Qur'an 11:50-60 (Surah Hud), 41:15-16, 46:21-26", "11:50-60, 41:15-16"),
    (99, "quran-story-the-owners-of-the-elephant", "quran_story", "The Owners of the Elephant — When Birds Defeated an Army", "Qur'an 105:1-5 (Surah al-Fil)", "105:1-5"),
    (101, "quran-story-abraha-and-the-kaaba", "quran_story", "Abraha and the Ka'ba — The Year of the Elephant", "Qur'an 105:1-5 (Surah al-Fil), Ibn Ishaq / al-Tabari historical reports", "105:1-5"),
    (104, "quran-story-the-battle-of-badr-in-quran", "quran_story", "The Battle of Badr in the Qur'an — Victory Through Patience", "Qur'an 3:123-126, 8:5-19 (Surah Aal Imran / al-Anfal)", "3:123-126, 8:5-19"),
    (108, "quran-story-the-battle-of-uhud-in-quran", "quran_story", "The Battle of Uhud in the Qur'an — Discipline Over Numbers", "Qur'an 3:121-122, 3:152-155 (Surah Aal Imran)", "3:121-122, 3:152-155"),
    (109, "quran-story-the-trench-in-quran", "quran_story", "The Trench in the Qur'an — When the Believers Dug Their Own Salvation", "Qur'an 33:9-27 (Surah al-Ahzab)", "33:9-27"),
    (110, "quran-story-the-conquest-of-mecca-in-quran", "quran_story", "The Conquest of Mecca in the Qur'an — Mercy Over Vengeance", "Qur'an 48:1-4, 110:1-3 (Surah al-Fath / al-Nasr)", "48:1-4, 110:1-3"),
    (111, "quran-story-the-night-journey", "quran_story", "The Night Journey (Isra') — From the Haram to the Aqsa", "Qur'an 17:1 (Surah al-Isra), Bukhari 3207, Muslim 263", "17:1"),
    (113, "quran-story-the-ascension-miraj", "quran_story", "The Ascension (Mi'raj) — When the Prophet ﷺ Met His Lord", "Qur'an 53:1-18, 17:60, 81:19-25; Bukhari 3207, Muslim 162", "53:1-18, 17:60, 81:19-25"),
    (114, "quran-story-the-first-revelation", "quran_story", "The First Revelation — 'Read in the Name of Your Lord'", "Qur'an 96:1-5 (Surah al-Alaq); Bukhari 4953, Muslim 160", "96:1-5"),
    (118, "quran-story-the-hijra", "quran_story", "The Hijra — When the Prophet ﷺ Left Everything for Allah", "Qur'an 9:40, 8:72 (Surah al-Tawba / al-Anfal); Bukhari 3905, Muslim 3018", "9:40, 8:72"),
    (119, "quran-story-the-munafiqun", "quran_story", "The Hypocrites (Munafiqun) — When Words Mask Hearts", "Qur'an 63:1-8 (Surah al-Munafiqun), 33:60-62", "63:1-8, 33:60-62"),
    (120, "quran-story-the-story-of-talut-and-jalut", "quran_story", "Talut and Jalut — The Test of Water and Obedience", "Qur'an 2:246-249 (Surah al-Baqara)", "2:246-249"),
    (121, "quran-story-the-story-of-uzayr", "quran_story", "Uzayr and the Dead City — A Hundred Years Pass in a Sleep", "Qur'an 2:259 (Surah al-Baqara)", "2:259"),
]

# =============================================================================
# BATCH 3 — hadith_narrative (lessons 41-60)
# =============================================================================
batch3 = [
    (123, "hadith-three-men-in-cave", "hadith_narrative", "The Three Men Trapped in a Cave — When Good Deeds Intercede", "Bukhari 2217, Muslim 2743", ""),
    (124, "hadith-man-who-killed-100", "hadith_narrative", "The Man Who Killed a Hundred — The Limitlessness of Allah's Mercy", "Bukhari 3470, Muslim 2766", ""),
    (125, "hadith-wealthy-man-and-two-gardens", "hadith_narrative", "The Man with Two Gardens — When Wealth Becomes a Trial", "Muslim 2963; Qur'an 18:32-44", ""),
    (128, "hadith-abu-dharr-and-charity", "hadith_narrative", "Abu Dharr and Charity — The Upper Hand is Better Than the Lower", "Bukhari 1427, Muslim 1035", ""),
    (129, "hadith-splitting-moon", "hadith_narrative", "The Splitting of the Moon — A Sign Denied", "Bukhari 3636, Muslim 2800; Qur'an 54:1", ""),
    (131, "hadith-seven-destroyers", "hadith_narrative", "The Seven Destructive Sins — Guardrails for the Soul", "Bukhari 2766, Muslim 89", ""),
    (133, "hadith-garden-for-preserver", "hadith_narrative", "A Guarantee of Paradise — Guarding the Tongue and the Private Parts", "Bukhari 6474", ""),
    (134, "hadith-muslim-brother", "hadith_narrative", "A Muslim Does Not Oppress Another — The Social Contract of Islam", "Bukhari 2442, Muslim 2580", ""),
    (138, "hadith-weeping-tree-stump", "hadith_narrative", "The Weeping Tree-Stump — When Even Wood Longed for the Prophet ﷺ", "Bukhari 3583-3585", ""),
    (139, "hadith-iman-77-branches", "hadith_narrative", "Iman Has Seventy-Odd Branches — Faith as a Structure", "Bukhari 9, Muslim 35", ""),
    (140, "hadith-prostitute-and-dog", "hadith_narrative", "A Prostitute Forgiven for Giving Water to a Dog — Mercy Has No Rank", "Bukhari 3467, Muslim 2245", ""),
    (141, "hadith-thirsty-dog", "hadith_narrative", "The Man Who Gave Water to a Thirsty Dog — Even Small Mercies Are Weighted", "Bukhari 2363, Muslim 2244", ""),
    (143, "hadith-cat-imprisoned", "hadith_narrative", "The Woman Punished Because of a Cat — Cruelty Has Consequences", "Bukhari 3482, Muslim 2242", ""),
    (144, "hadith-uways-al-qarni", "hadith_narrative", "Uways al-Qarni — Known in the Heavens, Unknown on Earth", "Muslim 2542", ""),
    (146, "hadith-hidden-treasure", "hadith_narrative", "'I Was a Hidden Treasure' — Why Isnad Criticism Matters", "Ibn Taymiyya, Majmu' al-Fatawa 18/122; al-Suyuti, al-Durar al-Muntathira 330", ""),
    (148, "hadith-seven-shaded", "hadith_narrative", "The Seven Whom Allah Will Shade — Seeking the Shade of the Throne", "Bukhari 660, Muslim 1031", ""),
    (149, "hadith-sahabi-who-gave-everything", "hadith_narrative", "The Sahabi Who Gave Everything — The Balance of Generosity", "Bukhari 1427, Muslim 1035", ""),
    (150, "hadith-man-who-asked-for-too-much", "hadith_narrative", "The Man Who Asked for Too Much — The Two Gardens Parable", "Muslim 2963; Qur'an 18:32-44", ""),
    (151, "hadith-jibril-and-iman-islam-ihsan", "hadith_narrative", "The Hadith of Jibril — Islam, Iman, and Ihsan Defined", "Muslim 8, Bukhari 50", ""),
    (153, "hadith-true-struggle", "hadith_narrative", "The True Struggle (Jihad al-Nafs) — Fighting the Inner Enemy", "Muslim 2581, Tirmidhi 1621", ""),
]

# =============================================================================
# BATCH 4 — hadith_narrative continued (lessons 61-80)
# =============================================================================
batch4 = [
    (154, "hadith-hellfire-wrapped-in-desires", "hadith_narrative", "Hellfire Wrapped in Desires and Paradise Wrapped in Hardships", "Bukhari 6487, Muslim 2822", ""),
    (155, "hadith-istighfar-and-rain", "hadith_narrative", "Seeking Forgiveness Brings the Rain — The Connection Between Sin and Drought", "Muslim 2740, Abu Dawud 1171", ""),
    (156, "hadith-five-before-five", "hadith_narrative", "Five Before Five — Seizing Life Before Death", "Hakim 4185, sahih; al-Albani, Sahih al-Targhib 1076", ""),
    (158, "hadith-trials-of-the-grave", "hadith_narrative", "The Trials of the Grave — Munkar and Nakir", "Tirmidhi 1071 (sahih), Abu Dawud 4753 (sahih)", ""),
    (159, "hadith-shafa'a-of-the-prophet", "hadith_narrative", "The Shafa'a of the Prophet ﷺ — The Greatest Station on the Day of Judgment", "Bukhari 4712, Muslim 193", ""),
    (161, "hadith-intercession-of-believers", "hadith_narrative", "The Intercession of Believers — When the Righteous Plead for Others", "Bukhari 7474, Muslim 263", ""),
    (163, "hadith-hawd-of-the-prophet", "hadith_narrative", "The Hawd (Basin) of the Prophet ﷺ — A River Wider Than the Distance of a Month's Journey", "Bukhari 6581, Muslim 2302", ""),
    (164, "hadith-straight-path-over-hellfire", "hadith_narrative", "The Straight Path Over Hellfire — Crossing the Sirat", "Bukhari 7439, Muslim 183", ""),
    (166, "hadith-scales-of-deeds", "hadith_narrative", "The Scales of Deeds — When a Single Good Deed Outweighs Mountains", "Muslim 4836, Tirmidhi 2634", ""),
    (168, "hadith-book-of-deeds", "hadith_narrative", "The Book of Deeds — Given in the Right Hand", "Bukhari 6538, Muslim 2762", ""),
    (169, "hadith-answering-in-grave", "hadith_narrative", "Answering in the Grave — The Believer's Testimony", "Tirmidhi 1071 (sahih), Abu Dawud 4751", ""),
    (170, "hadith-death-as-a-reminder", "hadith_narrative", "Death as a Reminder — Remember the Destroyer of Pleasures", "Tirmidhi 2307 (hasan), Ibn Majah 4258", ""),
    (171, "hadith-visiting-graves", "hadith_narrative", "Visiting Graves — A Lesson in Humility", "Muslim 977, Abu Dawud 3234", ""),
    (173, "hadith-dua-of-parents", "hadith_narrative", "The Dua of Parents — Faster Than the Sword", "Muslim 2620, Tirmidhi 1899", ""),
    (174, "hadith-obedience-to-parents", "hadith_narrative", "Obedience to Parents — Paradise at the Feet of Mothers", "Muslim 2548, Bukhari 5971", ""),
    (178, "hadith-rights-of-neighbors", "hadith_narrative", "The Rights of Neighbors — Almost Made Them Heirs", "Bukhari 6015, Muslim 2625", ""),
    (179, "hadith-smiling-in-face-of-brother", "hadith_narrative", "Smiling in the Face of Your Brother — A Charity", "Tirmidhi 1956 (hasan), Ibn Majah 3754", ""),
    (180, "hadith-removing-harm-from-path", "hadith_narrative", "Removing Harm from the Path — A Branch of Iman", "Muslim 35, Bukhari 9", ""),
    (181, "hadith-speaking-good-or-remaining-silent", "hadith_narrative", "Speak Good or Remain Silent — Guarding the Tongue", "Bukhari 6018, Muslim 47", ""),
]

# =============================================================================
# BATCH 5 — sunnah_practice (lessons 81-100)
# =============================================================================
batch5 = [
    (183, "sunnah-tahajjud-prayer", "sunnah_practice", "The Sunnah of Tahajjud — The Night Prayer", "Bukhari 1142, Muslim 758", ""),
    (184, "sunnah-witr-prayer", "sunnah_practice", "The Sunnah of Witr Prayer — The Odd Prayer Before Dawn", "Bukhari 990, Muslim 752", ""),
    (185, "sunnah-duha-prayer", "sunnah_practice", "The Sunnah of Duha (Forenoon) Prayer — Two Rak'ahs After Sunrise", "Muslim 719, Tirmidhi 476", ""),
    (188, "sunnah-qunut-in-witr", "sunnah_practice", "The Qunut in Witr — Supplication in the Last Rak'ah", "Bukhari 1001, Muslim 806", ""),
    (189, "sunnah-sujud-sahw", "sunnah_practice", "Sujud al-Sahw (Prostration of Forgetfulness) — Correcting Prayer Errors", "Bukhari 1224, Muslim 572", ""),
    (191, "sunnah-tashahhud", "sunnah_practice", "The Tashahhud in Prayer — The Testimony of the Sitting", "Bukhari 6264, Muslim 402", ""),
    (193, "sunnah-adhan-and-iqama", "sunnah_practice", "The Adhan and Iqama — Calling to Prayer", "Bukhari 604, Muslim 377", ""),
    (194, "sunnah-jumuah-prayer", "sunnah_practice", "The Sunnah of Jumu'ah — Friday Congregational Prayer", "Bukhari 891, Muslim 857", ""),
    (198, "sunnah-eid-prayer", "sunnah_practice", "The Sunnah of Eid Prayer — The Two Festivals", "Bukhari 956, Muslim 889", ""),
    (199, "sunnah-khutba", "sunnah_practice", "The Khutba (Sermon) — Addressing the Congregation", "Bukhari 928, Muslim 862", ""),
    (200, "sunnah-ruku-and-sujud", "sunnah_practice", "The Sunnah of Ruku' and Sujud — Bowing and Prostrating with Tranquility", "Bukhari 793, Muslim 543", ""),
    (201, "sunnah-reciting-aloud-and-silent", "sunnah_practice", "Reciting Aloud and Silent in Prayer — The Rulings of Jahr and Sirr", "Bukhari 761, Muslim 452", ""),
    (203, "sunnah-sutra-in-prayer", "sunnah_practice", "The Sutra in Prayer — Placing a Barrier Before the Worshipper", "Bukhari 505, Muslim 543", ""),
    (204, "sunnah-praying-in-congregation", "sunnah_practice", "Praying in Congregation — Twenty-Seven Times Better Than Alone", "Bukhari 645, Muslim 650", ""),
    (208, "sunnah-takbirat-of-eid", "sunnah_practice", "The Takbirat of Eid — Proclaiming Allah's Greatness", "Muslim 892, Abu Dawud 1140", ""),
    (209, "sunnah-saying-amin", "sunnah_practice", "Saying 'Amin' After al-Fatiha — When the Angels Say Amin", "Bukhari 780, Muslim 410", ""),
    (210, "sunnah-prayer-for-rain-istisqa", "sunnah_practice", "The Prayer for Rain (Istisqa) — Turning to Allah in Drought", "Bukhari 1005, Muslim 897", ""),
    (211, "sunnah-eclipse-prayer", "sunnah_practice", "The Eclipse Prayer (Kusuf) — When the Sun or Moon Is Eclipsed", "Bukhari 1043, Muslim 901", ""),
    (213, "sunnah-funeral-prayer", "sunnah_practice", "The Funeral Prayer (Janaza) — The Last Gift to a Muslim", "Bukhari 1240, Muslim 951", ""),
    (214, "sunnah-visiting-sick", "sunnah_practice", "The Sunnah of Visiting the Sick", "Bukhari 5659, Muslim 2191", ""),
]

# =============================================================================
# BATCH 6 — sunnah_practice continued (lessons 101-120)
# =============================================================================
batch6 = [
    (215, "sunnah-eating-etiquette", "sunnah_practice", "The Sunnah of Eating and Drinking", "Bukhari 5140, 5391, 5456; Tirmidhi 2380, 1853", ""),
    (218, "sunnah-sleeping-etiquette", "sunnah_practice", "The Sunnah of Sleeping — Preparing for the Night", "Bukhari 247, Muslim 2713", ""),
    (219, "sunnah-waking-up", "sunnah_practice", "The Sunnah of Waking Up — Starting the Day with Allah", "Bukhari 3794, Muslim 2711", ""),
    (221, "sunnah-entering-home", "sunnah_practice", "The Sunnah of Entering and Leaving the Home", "Muslim 2018, Tirmidhi 3461", ""),
    (223, "sunnah-salam-greeting", "sunnah_practice", "The Sunnah of Greeting with Salam", "Bukhari 6234, Muslim 2160", ""),
    (224, "sunnah-shaking-hands", "sunnah_practice", "The Sunnah of Shaking Hands — Spreading Love Among Muslims", "Bukhari 6263, Muslim 2733", ""),
    (227, "sunnah-ghusl-friday", "sunnah_practice", "The Sunnah of Ghusl on Friday", "Bukhari 877, Muslim 845", ""),
    (228, "sunnah-siwak", "sunnah_practice", "The Sunnah of Siwak — Cleaning the Teeth", "Bukhari 887, Muslim 252", ""),
    (229, "sunnah-fragrance", "sunnah_practice", "The Sunnah of Wearing Fragrance", "Bukhari 2543, Muslim 2253", ""),
    (230, "sunnah-right-foot-first", "sunnah_practice", "Starting with the Right Foot — Entering Masjid and Good Places", "Bukhari 163, Muslim 2719", ""),
    (231, "sunnah-dua-before-eating", "sunnah_practice", "The Du'a Before and After Eating", "Bukhari 5376, Muslim 2024", ""),
    (232, "sunnah-dua-entering-bathroom", "sunnah_practice", "The Du'a When Entering and Leaving the Bathroom", "Bukhari 142, Muslim 375", ""),
    (233, "sunnah-dua-leaving-home", "sunnah_practice", "The Du'a When Leaving Home", "Abu Dawud 5095 (sahih), Tirmidhi 3426", ""),
    (234, "sunnah-dua-traveling", "sunnah_practice", "The Du'a When Traveling", "Bukhari 2789, Muslim 1342", ""),
    (237, "sunnah-dua-entering-market", "sunnah_practice", "The Du'a When Entering the Marketplace", "Tirmidhi 3428 (hasan), Ibn Majah 2235", ""),
    (238, "sunnah-dua-after-adhan", "sunnah_practice", "The Du'a After the Adhan", "Bukhari 614, Muslim 386", ""),
    (239, "sunnah-dua-between-sujud", "sunnah_practice", "The Du'a Between the Two Sujuds", "Bukhari 738, Muslim 476", ""),
    (240, "sunnah-dua-qunut", "sunnah_practice", "The Du'a of Qunut in Witr and Fajr", "Bukhari 1001, Muslim 806", ""),
    (241, "sunnah-dua-ruku-sujud", "sunnah_practice", "The Du'as of Ruku' and Sujud", "Bukhari 794, Muslim 484", ""),
    (242, "sunnah-dua-tashahhud", "sunnah_practice", "The Tashahhud and Sending Salawat on the Prophet ﷺ", "Bukhari 6264, Muslim 402, 406", ""),
]

# =============================================================================
# BATCH 7 — quran_hadith_fact (lessons 121-140)
# =============================================================================
batch7 = [
    (243, "quran-fact-basmala-meaning", "quran_hadith_fact", "Why Does the Qur'an Begin with 'Bismillah al-Rahman al-Rahim'?", "Qur'an 1:1; al-Qurtubi, al-Jami' li-Ahkam al-Qur'an", "1:1"),
    (244, "quran-fact-hamd-meaning", "quran_hadith_fact", "What Does 'Alhamdulillah' Actually Mean?", "Qur'an 1:2; al-Zajjaj, Ma'ani al-Qur'an; al-Raghib al-Isfahani, al-Mufradat", "1:2"),
    (245, "quran-fact-why-quran-repeats", "quran_hadith_fact", "Why Does the Qur'an Repeat Certain Phrases and Stories?", "Qur'an 39:23; Ibn Kathir, Tafsir; al-Suyuti, al-Itqan fi 'Ulum al-Qur'an", "39:23"),
    (247, "quran-fact-seven-mathani", "quran_hadith_fact", "The Seven Oft-Repeated Verses — Why Is al-Fatiha So Central?", "Qur'an 15:87; Bukhari 4474, Muslim 394", "15:87"),
    (248, "quran-fact-why-arabic", "quran_hadith_fact", "Why Was the Qur'an Revealed in Arabic?", "Qur'an 12:2, 20:113, 39:28; Ibn Kathir, Tafsir", "12:2, 20:113, 39:28"),
    (249, "quran-fact-abrogation", "quran_hadith_fact", "Abrogation in the Qur'an — What Is Naskh and Why Did It Happen?", "Qur'an 2:106, 16:101; Ibn Kathir, Tafsir; al-Suyuti, al-Itqan", "2:106, 16:101"),
    (251, "quran-fact-makki-vs-madani", "quran_hadith_fact", "Makki vs. Madani Surahs — The Difference in Style and Content", "Qur'an 20:1, 2:1; Ibn Kathir, Tafsir; al-Suyuti, al-Itqan", ""),
    (252, "quran-fact-qiraat-seven", "quran_hadith_fact", "The Seven Qira'at — Why Are There Different Readings of the Qur'an?", "Bukhari 5006, Muslim 819; Ibn al-Jazari, al-Nashr fi al-Qira'at al-Ashr", ""),
    (253, "quran-fact-preservation", "quran_hadith_fact", "How Was the Qur'an Preserved? — Compilation Under Abu Bakr and Uthman", "Bukhari 4986, 4987, Muslim 1050; Ibn Kathir, al-Bidaya wa-l-Nihaya", ""),
    (254, "quran-fact-ijaz", "quran_hadith_fact", "The I'jaz (Inimitability) of the Qur'an — Why It Cannot Be Matched", "Qur'an 2:23, 10:38, 17:88; al-Baqillani, I'jaz al-Qur'an", "2:23, 10:38, 17:88"),
    (257, "quran-fact-asbab-al-nuzul", "quran_hadith_fact", "Asbab al-Nuzul — Why Context Matters in Tafsir", "Wahidi, Asbab al-Nuzul; Ibn Kathir, Tafsir; Suyuti, Lubab al-Nuqul", ""),
    (258, "quran-fact-huruf-muqatta'a", "quran_hadith_fact", "The Disjointed Letters (Huruf Muqatta'a) — What Do Alif Lam Mim Mean?", "Qur'an 2:1, 3:1, 7:1, etc.; Ibn Kathir, Tafsir; al-Razi, Mafatih al-Ghayb", "2:1, 3:1, 7:1"),
    (259, "quran-fact-tafsir-types", "quran_hadith_fact", "The Types of Tafsir — Riwaya vs. Diraya", "Ibn Kathir, Tafsir (introduction); al-Zarkashi, al-Burhan fi 'Ulum al-Qur'an", ""),
    (260, "quran-fact-occasions-of-revelation", "quran_hadith_fact", "Occasions of Revelation — When and Why Verses Were Revealed", "Wahidi, Asbab al-Nuzul; Ibn Kathir, Tafsir", ""),
    (261, "quran-fact-muhkam-and-mutashabih", "quran_hadith_fact", "Muhkam and Mutashabih — Clear Verses and Ambiguous Verses", "Qur'an 3:7; Ibn Kathir, Tafsir; al-Qurtubi, al-Jami'", "3:7"),
    (262, "quran-fact-why-ramadan", "quran_hadith_fact", "Why Was Ramadan Chosen for Fasting?", "Qur'an 2:185; Bukhari 1901, Muslim 1079; Ibn Kathir, Tafsir", "2:185"),
    (263, "quran-fact-zakat-purpose", "quran_hadith_fact", "What Is the True Purpose of Zakat?", "Qur'an 9:60, 2:177, 2:261; Ibn Kathir, Tafsir; al-Qurtubi, al-Jami'", "9:60, 2:177, 2:261"),
    (264, "quran-fact-hajj-wisdom", "quran_hadith_fact", "The Wisdom of Hajj — Why These Specific Rituals?", "Qur'an 2:125-127, 22:27-28; Ibn Kathir, Tafsir; al-Qurtubi, al-Jami'", "2:125-127, 22:27-28"),
    (267, "quran-fact-salawat-on-prophet", "quran_hadith_fact", "Why Do Muslims Send Salawat on the Prophet ﷺ?", "Qur'an 33:56; Bukhari 6357, Muslim 408; Ibn Kathir, Tafsir", "33:56"),
    (268, "quran-fact-jihad-meaning", "quran_hadith_fact", "What Does Jihad Actually Mean in the Qur'an and Sunnah?", "Qur'an 29:69, 22:78, 25:52; Bukhari 40, Muslim 4636; Ibn Kathir, Tafsir", "29:69, 22:78, 25:52"),
]

# =============================================================================
# BATCH 8 — quran_hadith_fact continued (lessons 141-160)
# =============================================================================
batch8 = [
    (269, "quran-fact-why-five-prayers", "quran_hadith_fact", "Why Five Daily Prayers? — The Night Journey and the Command", "Bukhari 3207, Muslim 263; Ibn Kathir, al-Bidaya wa-l-Nihaya", ""),
    (270, "quran-fact-ruku-sujud-wisdom", "quran_hadith_fact", "The Wisdom of Ruku' and Sujud — Bowing and Prostrating Before Allah", "Muslim 541, Bukhari 433; Ibn al-Qayyim, Zad al-Ma'ad", ""),
    (271, "quran-fact-why-hijab", "quran_hadith_fact", "What Does the Qur'an Say About Hijab?", "Qur'an 24:31, 33:59; Bukhari 4481, Muslim 2126; Ibn Kathir, Tafsir", "24:31, 33:59"),
    (272, "quran-fact-marriage-in-islam", "quran_hadith_fact", "Marriage in Islam — The Qur'anic Vision of Spousal Relations", "Qur'an 30:21, 4:1, 2:187; Bukhari 4903, Muslim 1468; Ibn Kathir, Tafsir", "30:21, 4:1, 2:187"),
    (273, "quran-fact-orphans-and-justice", "quran_hadith_fact", "The Rights of Orphans — A Repeated Command in the Qur'an", "Qur'an 2:220, 4:2, 4:10, 93:9; Bukhari 4898, Muslim 2983", "2:220, 4:2, 4:10, 93:9"),
    (274, "quran-fact-interest-riba", "quran_hadith_fact", "Why Is Riba (Interest) Forbidden? — The Qur'anic Prohibition", "Qur'an 2:275-279, 3:130, 4:161, 30:39; Muslim 1584, Bukhari 2286", "2:275-279, 3:130, 4:161, 30:39"),
    (275, "quran-fact-intoxicants", "quran_hadith_fact", "The Gradual Prohibition of Intoxicants — A Lesson in Legislation", "Qur'an 2:219, 4:43, 5:90-91; Bukhari 4619, Muslim 1980; Ibn Kathir, Tafsir", "2:219, 4:43, 5:90-91"),
    (277, "quran-fact-why-pork-forbidden", "quran_hadith_fact", "Why Is Pork Forbidden in Islam?", "Qur'an 2:173, 5:3, 6:145, 16:115; Bukhari 2575, Muslim 1934", "2:173, 5:3, 6:145, 16:115"),
    (278, "quran-fact-mercy-in-punishment", "quran_hadith_fact", "Mercy in Islamic Punishments — The Conditions of Hudud", "Qur'an 24:2, 5:38, 17:32; Bukhari 6789, Muslim 1690; al-Qurtubi, al-Jami'", "24:2, 5:38, 17:32"),
    (279, "quran-fact-tawakkul", "quran_hadith_fact", "Tawakkul — Trusting Allah While Tying Your Camel", "Qur'an 3:159, 11:123, 25:58; Tirmidhi 2517 (hasan); Ibn Kathir, Tafsir", "3:159, 11:123, 25:58"),
    (281, "quran-fact-sabr-shukr", "quran_hadith_fact", "Patience and Gratitude — The Two Wings of the Believer", "Qur'an 2:155-157, 14:7; Muslim 2999, Tirmidhi 2308; Ibn al-Qayyim, Madarij al-Salikin", "2:155-157, 14:7"),
    (282, "quran-fact-tawba", "quran_hadith_fact", "Tawba (Repentance) — The Door That Never Closes", "Qur'an 39:53-54, 66:8, 2:222; Bukhari 6306, Muslim 2759; Ibn Kathir, Tafsir", "39:53-54, 66:8, 2:222"),
    (283, "quran-fact-khushu-in-prayer", "quran_hadith_fact", "Khushu' in Prayer — The Meaning of Humility Before Allah", "Qur'an 23:2, 2:238; Muslim 775, Bukhari 324; Ibn al-Qayyim, al-Fawaid", "23:2, 2:238"),
    (284, "quran-fact-why-dhikr-matters", "quran_hadith_fact", "Why Does Dhikr Matter So Much? — The Qur'anic Command to Remember Allah", "Qur'an 13:28, 33:35, 33:41-42; Muslim 2704, Bukhari 6406; al-Nawawi, al-Adhkar", "13:28, 33:35, 33:41-42"),
    (285, "quran-fact-love-of-allah", "quran_hadith_fact", "The Love of Allah — What the Qur'an and Hadith Say About Divine Love", "Qur'an 2:165, 3:31, 5:54, 9:24; Bukhari 6041, Muslim 145; Ibn al-Qayyim, Madarij al-Salikin", "2:165, 3:31, 5:54, 9:24"),
    (287, "quran-fact-fear-of-allah", "quran_hadith_fact", "The Fear of Allah (Khashya) — A Balanced Reverence", "Qur'an 3:102, 35:28, 59:18; Bukhari 6429, Muslim 2728; Ibn Rajab, Jami' al-Ulum wa-l-Hikam", "3:102, 35:28, 59:18"),
    (288, "quran-fact-hope-in-allah", "quran_hadith_fact", "Hope in Allah (Raja') — Between Despair and Presumption", "Qur'an 12:87, 39:53, 94:5-6; Muslim 2577, Tirmidhi 3518; Ibn al-Qayyim, Madarij al-Salikin", "12:87, 39:53, 94:5-6"),
    (289, "quran-fact-sincerity-ikhlas", "quran_hadith_fact", "Ikhlas (Sincerity) — The Hidden Foundation of Every Deed", "Qur'an 98:5, 39:2, 38:46; Muslim 2985, Bukhari 1; Ibn Rajab, Jami' al-Ulum wa-l-Hikam", "98:5, 39:2, 38:46"),
    (290, "quran-fact-intention-niyya", "quran_hadith_fact", "The Intention (Niyya) — Why Actions Are Judged by Intentions", "Bukhari 1, Muslim 1907; Ibn Rajab, Jami' al-Ulum wa-l-Hikam; al-Nawawi, Sharh Sahih Muslim", ""),
    (291, "quran-fact-knowledge-in-islam", "quran_hadith_fact", "Knowledge in Islam — The First Word Revealed Was 'Read'", "Qur'an 96:1, 20:114, 58:11; Bukhari 71, Muslim 2393; Ibn Kathir, Tafsir", "96:1, 20:114, 58:11"),
]

# Verify counts
print(f"Batch 1: {len(batch1)} lessons")
print(f"Batch 2: {len(batch2)} lessons")
print(f"Batch 3: {len(batch3)} lessons")
print(f"Batch 4: {len(batch4)} lessons")
print(f"Batch 5: {len(batch5)} lessons")
print(f"Batch 6: {len(batch6)} lessons")
print(f"Batch 7: {len(batch7)} lessons")
print(f"Batch 8: {len(batch8)} lessons")
print(f"Total: {sum(len(b) for b in [batch1, batch2, batch3, batch4, batch5, batch6, batch7, batch8])} lessons")

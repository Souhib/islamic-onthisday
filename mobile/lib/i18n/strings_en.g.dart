///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppEn app = TranslationsAppEn._(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn._(_root);
	late final TranslationsTodayEn today = TranslationsTodayEn._(_root);
	late final TranslationsVerificationEn verification = TranslationsVerificationEn._(_root);
	late final TranslationsDisputeEn dispute = TranslationsDisputeEn._(_root);
	late final TranslationsNavEn nav = TranslationsNavEn._(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsErrorsEn errors = TranslationsErrorsEn._(_root);
	late final TranslationsBookmarksEn bookmarks = TranslationsBookmarksEn._(_root);
	late final TranslationsEventEn event = TranslationsEventEn._(_root);
	late final TranslationsPersonEn person = TranslationsPersonEn._(_root);
	late final TranslationsAboutEn about = TranslationsAboutEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsLegalEn legal = TranslationsLegalEn._(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Thaqafa'
	String get name => 'Thaqafa';

	/// en: 'The classical record. One day at a time.'
	String get tagline => 'The classical record. One day at a time.';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'In our time of days'
	String get eyebrow => 'In our time of days';

	/// en: 'The classical record, one day at a time.'
	String get headline => 'The classical record,\none day at a time.';

	/// en: 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.'
	String get subhead => 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.';

	/// en: 'Begin'
	String get begin => 'Begin';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Continue'
	String get kContinue => 'Continue';

	/// en: 'Choose your tongue'
	String get lang_eyebrow => 'Choose your tongue';

	/// en: 'Read in your language.'
	String get lang_headline => 'Read in your language.';

	/// en: 'The reading and its sources are translated into English, French, and Arabic. You can switch later from Settings.'
	String get lang_subhead => 'The reading and its sources are translated into English, French, and Arabic. You can switch later from Settings.';

	/// en: 'English'
	String get lang_en => 'English';

	/// en: 'Français'
	String get lang_fr => 'Français';

	/// en: 'العربية'
	String get lang_ar => 'العربية';

	/// en: 'A comfortable read'
	String get size_eyebrow => 'A comfortable read';

	/// en: 'Pick a size that feels right.'
	String get size_headline => 'Pick a size that feels right.';

	/// en: 'You can change this later in Settings — or pinch with two fingers to zoom anywhere in the app.'
	String get size_subhead => 'You can change this later in Settings — or pinch with two fingers to zoom anywhere in the app.';

	/// en: 'The classical record, one day at a time. Every entry is rooted in classical Sunni sources — al-Ṭabarī, Ibn Kathīr, the Six Books. Read it once a day, set a quiet reminder, and let the calendar bring you back tomorrow.'
	String get size_preview => 'The classical record, one day at a time. Every entry is rooted in classical Sunni sources — al-Ṭabarī, Ibn Kathīr, the Six Books. Read it once a day, set a quiet reminder, and let the calendar bring you back tomorrow.';

	/// en: 'A daily moment'
	String get notif_eyebrow => 'A daily moment';

	/// en: 'One quiet reminder, once a day.'
	String get notif_headline => 'One quiet reminder, once a day.';

	/// en: 'Pick the hour that fits your routine. We don't push notifications for anything else — and you can turn this off any time.'
	String get notif_subhead => 'Pick the hour that fits your routine. We don\'t push notifications for anything else — and you can turn this off any time.';

	/// en: 'Daily notification'
	String get notif_enable => 'Daily notification';

	/// en: 'Reminder time'
	String get notif_time => 'Reminder time';
}

// Path: today
class TranslationsTodayEn {
	TranslationsTodayEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get title => 'Today';

	/// en: 'loading'
	String get loading => 'loading';

	/// en: 'Couldn't load today.'
	String get load_failed => 'Couldn\'t load today.';

	/// en: 'More reading for today'
	String get more_reading => 'More reading for today';

	/// en: 'Introduction'
	String get introduction => 'Introduction';

	/// en: 'The reading'
	String get the_reading => 'The reading';

	/// en: 'End of the day's reading'
	String get end_of_reading => 'End of the day\'s reading';

	/// en: 'Verify'
	String get verify => 'Verify';
}

// Path: verification
class TranslationsVerificationEn {
	TranslationsVerificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scholar-reviewed'
	String get scholar_reviewed => 'Scholar-reviewed';

	/// en: 'Multiple sources'
	String get cross_verified => 'Multiple sources';

	/// en: 'One source'
	String get single_source => 'One source';

	/// en: 'Unverified'
	String get unverified => 'Unverified';
}

// Path: dispute
class TranslationsDisputeEn {
	TranslationsDisputeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'disputed date'
	String get date => 'disputed date';

	/// en: 'disputed detail'
	String get detail => 'disputed detail';

	/// en: 'disputed interpretation'
	String get interpretation => 'disputed interpretation';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Recent'
	String get recent => 'Recent';

	/// en: 'Sacred days'
	String get observances => 'Sacred days';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Light'
	String get theme_light => 'Light';

	/// en: 'Dark'
	String get theme_dark => 'Dark';

	/// en: 'System'
	String get theme_system => 'System';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Reading size'
	String get reading_size => 'Reading size';

	/// en: 'S'
	String get reading_size_s => 'S';

	/// en: 'M'
	String get reading_size_m => 'M';

	/// en: 'L'
	String get reading_size_l => 'L';

	/// en: 'XL'
	String get reading_size_xl => 'XL';

	/// en: 'Daily notification'
	String get notifications => 'Daily notification';

	/// en: 'Notification time'
	String get notification_time => 'Notification time';

	/// en: 'Today on the calendar'
	String get notification_title => 'Today on the calendar';

	/// en: 'A new entry awaits. Open to read.'
	String get notification_body => 'A new entry awaits. Open to read.';

	/// en: 'Send a test notification'
	String get notification_test => 'Send a test notification';

	/// en: 'Thaqafa — test'
	String get notification_test_title => 'Thaqafa — test';

	/// en: 'If you can read this, notifications are working.'
	String get notification_test_body => 'If you can read this, notifications are working.';

	/// en: 'A test notification will arrive in about five seconds.'
	String get notification_test_pending => 'A test notification will arrive in about five seconds.';

	/// en: 'Notifications are enabled in the app but blocked by iOS. Open the system Settings to allow them.'
	String get notification_permission_warning => 'Notifications are enabled in the app but blocked by iOS. Open the system Settings to allow them.';

	/// en: 'Open system settings'
	String get notification_open_system_settings => 'Open system settings';

	/// en: 'Browse sacred days'
	String get observances_link => 'Browse sacred days';

	/// en: 'About'
	String get about => 'About';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Something went wrong.'
	String get generic => 'Something went wrong.';

	/// en: 'You appear to be offline.'
	String get offline => 'You appear to be offline.';

	/// en: 'Not found.'
	String get not_found => 'Not found.';
}

// Path: bookmarks
class TranslationsBookmarksEn {
	TranslationsBookmarksEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Saved'
	String get title => 'Saved';

	/// en: 'Nothing saved yet. Tap save on an entry to keep it for later.'
	String get empty => 'Nothing saved yet. Tap save on an entry to keep it for later.';
}

// Path: event
class TranslationsEventEn {
	TranslationsEventEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sources'
	String get sources => 'Sources';

	/// en: 'People'
	String get people => 'People';

	/// en: 'classical'
	String get source_classical => 'classical';

	/// en: 'primary'
	String get source_primary => 'primary';

	/// en: 'modern'
	String get source_modern => 'modern';

	/// en: 'primary'
	String get weight_primary => 'primary';

	/// en: 'notable'
	String get weight_notable => 'notable';

	/// en: 'minority'
	String get weight_minority => 'minority';

	/// en: 'Attested positions'
	String get disputed_drawer_title => 'Attested positions';

	/// en: 'Classical Sunni sources disagree on this point. The positions are listed in order of attestation.'
	String get disputed_drawer_intro => 'Classical Sunni sources disagree on this point. The positions are listed in order of attestation.';
}

// Path: person
class TranslationsPersonEn {
	TranslationsPersonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Person'
	String get eyebrow => 'Person';

	/// en: 'Biography'
	String get biography => 'Biography';

	/// en: 'Out of reverence, no image of the Prophets ﷺ is shown.'
	String get restricted_prophet => 'Out of reverence, no image of the Prophets ﷺ is shown.';

	/// en: 'By policy, no AI-generated image of a Sahabi is shown.'
	String get restricted_sahabi => 'By policy, no AI-generated image of a Sahabi is shown.';

	/// en: 'By policy, no AI-generated image of the Ahl al-Bayt is shown.'
	String get restricted_ahl_al_bayt => 'By policy, no AI-generated image of the Ahl al-Bayt is shown.';
}

// Path: about
class TranslationsAboutEn {
	TranslationsAboutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About'
	String get nav_label => 'About';

	/// en: 'About the project · About me'
	String get title => 'About the project · About me';

	/// en: 'A few words on what this is, who built it, and how to reach out.'
	String get subtitle => 'A few words on what this is, who built it, and how to reach out.';

	/// en: 'Souhib Trabelsi'
	String get name => 'Souhib Trabelsi';

	/// en: 'Software engineer'
	String get role => 'Software engineer';

	/// en: 'I'm a software engineer with seven years of experience, mostly in Python and React. I started Thaqafa because I wanted a daily reading habit anchored in classical Islamic history. Every entry is hand-verified against official sources before it ships.'
	String get bio => 'I\'m a software engineer with seven years of experience, mostly in Python and React. I started Thaqafa because I wanted a daily reading habit anchored in classical Islamic history. Every entry is hand-verified against official sources before it ships.';

	/// en: 'What is Thaqafa?'
	String get project_purpose_title => 'What is Thaqafa?';

	/// en: 'A verified event from Islamic history every day, in both Hijri and Gregorian calendars. Every entry — event, lesson, sacred day — is hand-verified against classical sources (al-Ṭabarī, Ibn Kathīr, the Six Books) before it's published. We drop a borderline entry rather than keep a wrong one. The promise is unconditional: every entry has been editorially reviewed.'
	String get project_purpose_body => 'A verified event from Islamic history every day, in both Hijri and Gregorian calendars. Every entry — event, lesson, sacred day — is hand-verified against classical sources (al-Ṭabarī, Ibn Kathīr, the Six Books) before it\'s published. We drop a borderline entry rather than keep a wrong one. The promise is unconditional: every entry has been editorially reviewed.';

	/// en: 'Education'
	String get education_title => 'Education';

	/// en: 'Epitech Paris — Master's in Software Engineering'
	String get education_epitech => 'Epitech Paris — Master\'s in Software Engineering';

	/// en: 'San Francisco State University — Certificate'
	String get education_sfsu => 'San Francisco State University — Certificate';

	/// en: 'Experience'
	String get experience_title => 'Experience';

	/// en: 'Madura Capital Management — Python Developer / DevOps'
	String get experience_madura_title => 'Madura Capital Management — Python Developer / DevOps';

	/// en: 'September 2024 — present'
	String get experience_madura_period => 'September 2024 — present';

	/// en: 'Internal tooling for a hedge fund — data feeders, Prefect ETL pipelines, React/TypeScript trading UI.'
	String get experience_madura_desc => 'Internal tooling for a hedge fund — data feeders, Prefect ETL pipelines, React/TypeScript trading UI.';

	/// en: 'Snapchat (SnapLab) — Python Developer / DevOps / AWS'
	String get experience_snap_title => 'Snapchat (SnapLab) — Python Developer / DevOps / AWS';

	/// en: 'May 2022 — September 2024'
	String get experience_snap_period => 'May 2022 — September 2024';

	/// en: 'Session-recording dashboard for Snap's Connected Spectacles team. FastAPI backend on AWS ECS via Terraform; React frontend.'
	String get experience_snap_desc => 'Session-recording dashboard for Snap\'s Connected Spectacles team. FastAPI backend on AWS ECS via Terraform; React frontend.';

	/// en: 'Enedis (EDF) — Python Developer / DevOps / Cloud'
	String get experience_enedis_title => 'Enedis (EDF) — Python Developer / DevOps / Cloud';

	/// en: 'April 2021 — April 2022'
	String get experience_enedis_period => 'April 2021 — April 2022';

	/// en: 'Customer-request platform with chat. FastAPI on AWS Lambda (Serverless framework); React/TypeScript frontend.'
	String get experience_enedis_desc => 'Customer-request platform with chat. FastAPI on AWS Lambda (Serverless framework); React/TypeScript frontend.';

	/// en: 'BNP Paribas Personal Finance — Python Developer / DevOps'
	String get experience_bnp_title => 'BNP Paribas Personal Finance — Python Developer / DevOps';

	/// en: 'September 2019 — March 2021'
	String get experience_bnp_period => 'September 2019 — March 2021';

	/// en: 'Migrated monolith to microservices. Python APIs giving data scientists secure access to large datasets via NAS-backed IDE sessions.'
	String get experience_bnp_desc => 'Migrated monolith to microservices. Python APIs giving data scientists secure access to large datasets via NAS-backed IDE sessions.';

	/// en: 'Cloudeasier (Accenture) — Python / Cloud Developer'
	String get experience_cloudeasier_title => 'Cloudeasier (Accenture) — Python / Cloud Developer';

	/// en: 'February 2019 — August 2019'
	String get experience_cloudeasier_period => 'February 2019 — August 2019';

	/// en: 'Python on AWS Lambda + GCP Cloud Functions for compute pricing and scheduling. Terraform-deployed.'
	String get experience_cloudeasier_desc => 'Python on AWS Lambda + GCP Cloud Functions for compute pricing and scheduling. Terraform-deployed.';

	/// en: 'Skills'
	String get skills_title => 'Skills';

	/// en: 'Other projects'
	String get other_projects_title => 'Other projects';

	/// en: 'Majlisna'
	String get other_projects_majlisna_title => 'Majlisna';

	/// en: 'A real-time multiplayer party-game platform with Islamized variants of Undercover and Codenames.'
	String get other_projects_majlisna_desc => 'A real-time multiplayer party-game platform with Islamized variants of Undercover and Codenames.';

	/// en: 'majlisna.app'
	String get other_projects_majlisna_link => 'majlisna.app';

	/// en: 'LaTabdhir'
	String get other_projects_latabdhir_title => 'LaTabdhir';

	/// en: 'A dhikr counter built around daily reminders and streaks.'
	String get other_projects_latabdhir_desc => 'A dhikr counter built around daily reminders and streaks.';

	/// en: 'latabdhir.ae'
	String get other_projects_latabdhir_link => 'latabdhir.ae';

	/// en: 'Free mentoring'
	String get mentoring_title => 'Free mentoring';

	/// en: 'With my experience I can help CS engineers, developers, or anyone who wants to learn more about computer science — freely. I can also help with your resume, understanding the job market, preparing for interviews, or giving general advice when looking for jobs. Contact me via email or phone. If I don't answer, leave a message and I'll call you back.'
	String get mentoring_body => 'With my experience I can help CS engineers, developers, or anyone who wants to learn more about computer science — freely. I can also help with your resume, understanding the job market, preparing for interviews, or giving general advice when looking for jobs. Contact me via email or phone. If I don\'t answer, leave a message and I\'ll call you back.';

	/// en: 'Support the Ummah'
	String get charity_title => 'Support the Ummah';

	/// en: 'If this project is useful to you, please consider a donation to one of these.'
	String get charity_subtitle => 'If this project is useful to you, please consider a donation to one of these.';

	/// en: 'International humanitarian charity working in conflict zones, food security, and orphan support.'
	String get charity_human_appeal_desc => 'International humanitarian charity working in conflict zones, food security, and orphan support.';

	/// en: 'Long-running French charity active in education, water access, and emergency relief.'
	String get charity_ummah_charity_desc => 'Long-running French charity active in education, water access, and emergency relief.';

	/// en: 'Donate'
	String get charity_donate => 'Donate';

	/// en: 'Get in touch'
	String get contact_title => 'Get in touch';

	/// en: 'Email'
	String get contact_email => 'Email';

	/// en: 'Phone'
	String get contact_phone => 'Phone';

	/// en: 'LinkedIn'
	String get contact_linkedin => 'LinkedIn';

	/// en: 'GitHub'
	String get contact_github => 'GitHub';

	/// en: 'Qur'an editions'
	String get quran_attribution_title => 'Qur\'an editions';

	/// en: 'Arabic text from Tanzil's ʿUthmānī Mushaf. English translation by Saheeh International. French translation by Muḥammad Hamidullah. The verse rendered above the footer is selected from the day's event citations when available, with Sūrat Yūsuf 12:111 — "there is a lesson for those of understanding" — as the standing fallback.'
	String get quran_attribution_body => 'Arabic text from Tanzil\'s ʿUthmānī Mushaf. English translation by Saheeh International. French translation by Muḥammad Hamidullah. The verse rendered above the footer is selected from the day\'s event citations when available, with Sūrat Yūsuf 12:111 — "there is a lesson for those of understanding" — as the standing fallback.';

	/// en: 'Created by'
	String get created_by => 'Created by';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Sign in'
	String get sign_in => 'Sign in';

	/// en: 'Create account'
	String get sign_up => 'Create account';

	/// en: 'Sign out'
	String get sign_out => 'Sign out';

	/// en: 'Welcome back.'
	String get sign_in_title => 'Welcome back.';

	/// en: 'Create an account.'
	String get sign_up_title => 'Create an account.';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Display name'
	String get display_name => 'Display name';

	/// en: 'No account? Create one'
	String get no_account_cta => 'No account? Create one';

	/// en: 'Already have an account? Sign in'
	String get have_account_cta => 'Already have an account? Sign in';

	/// en: 'Delete account'
	String get delete_account_cta => 'Delete account';

	/// en: 'Delete account?'
	String get delete_account_title => 'Delete account?';

	/// en: 'This permanently removes your account and every saved bookmark. The action cannot be undone.'
	String get delete_account_warning => 'This permanently removes your account and every saved bookmark. The action cannot be undone.';

	/// en: 'Cancel'
	String get delete_account_cancel => 'Cancel';

	/// en: 'Delete forever'
	String get delete_account_confirm => 'Delete forever';
}

// Path: legal
class TranslationsLegalEn {
	TranslationsLegalEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Legal'
	String get title => 'Legal';

	/// en: 'Privacy Policy'
	String get privacy => 'Privacy Policy';

	/// en: 'Terms of Service'
	String get terms => 'Terms of Service';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Thaqafa',
			'app.tagline' => 'The classical record. One day at a time.',
			'onboarding.eyebrow' => 'In our time of days',
			'onboarding.headline' => 'The classical record,\none day at a time.',
			'onboarding.subhead' => 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.',
			'onboarding.begin' => 'Begin',
			'onboarding.skip' => 'Skip',
			'onboarding.kContinue' => 'Continue',
			'onboarding.lang_eyebrow' => 'Choose your tongue',
			'onboarding.lang_headline' => 'Read in your language.',
			'onboarding.lang_subhead' => 'The reading and its sources are translated into English, French, and Arabic. You can switch later from Settings.',
			'onboarding.lang_en' => 'English',
			'onboarding.lang_fr' => 'Français',
			'onboarding.lang_ar' => 'العربية',
			'onboarding.size_eyebrow' => 'A comfortable read',
			'onboarding.size_headline' => 'Pick a size that feels right.',
			'onboarding.size_subhead' => 'You can change this later in Settings — or pinch with two fingers to zoom anywhere in the app.',
			'onboarding.size_preview' => 'The classical record, one day at a time. Every entry is rooted in classical Sunni sources — al-Ṭabarī, Ibn Kathīr, the Six Books. Read it once a day, set a quiet reminder, and let the calendar bring you back tomorrow.',
			'onboarding.notif_eyebrow' => 'A daily moment',
			'onboarding.notif_headline' => 'One quiet reminder, once a day.',
			'onboarding.notif_subhead' => 'Pick the hour that fits your routine. We don\'t push notifications for anything else — and you can turn this off any time.',
			'onboarding.notif_enable' => 'Daily notification',
			'onboarding.notif_time' => 'Reminder time',
			'today.title' => 'Today',
			'today.loading' => 'loading',
			'today.load_failed' => 'Couldn\'t load today.',
			'today.more_reading' => 'More reading for today',
			'today.introduction' => 'Introduction',
			'today.the_reading' => 'The reading',
			'today.end_of_reading' => 'End of the day\'s reading',
			'today.verify' => 'Verify',
			'verification.scholar_reviewed' => 'Scholar-reviewed',
			'verification.cross_verified' => 'Multiple sources',
			'verification.single_source' => 'One source',
			'verification.unverified' => 'Unverified',
			'dispute.date' => 'disputed date',
			'dispute.detail' => 'disputed detail',
			'dispute.interpretation' => 'disputed interpretation',
			'nav.today' => 'Today',
			'nav.recent' => 'Recent',
			'nav.observances' => 'Sacred days',
			'nav.settings' => 'Settings',
			'settings.title' => 'Settings',
			'settings.appearance' => 'Appearance',
			'settings.theme_light' => 'Light',
			'settings.theme_dark' => 'Dark',
			'settings.theme_system' => 'System',
			'settings.language' => 'Language',
			'settings.reading_size' => 'Reading size',
			'settings.reading_size_s' => 'S',
			'settings.reading_size_m' => 'M',
			'settings.reading_size_l' => 'L',
			'settings.reading_size_xl' => 'XL',
			'settings.notifications' => 'Daily notification',
			'settings.notification_time' => 'Notification time',
			'settings.notification_title' => 'Today on the calendar',
			'settings.notification_body' => 'A new entry awaits. Open to read.',
			'settings.notification_test' => 'Send a test notification',
			'settings.notification_test_title' => 'Thaqafa — test',
			'settings.notification_test_body' => 'If you can read this, notifications are working.',
			'settings.notification_test_pending' => 'A test notification will arrive in about five seconds.',
			'settings.notification_permission_warning' => 'Notifications are enabled in the app but blocked by iOS. Open the system Settings to allow them.',
			'settings.notification_open_system_settings' => 'Open system settings',
			'settings.observances_link' => 'Browse sacred days',
			'settings.about' => 'About',
			'errors.generic' => 'Something went wrong.',
			'errors.offline' => 'You appear to be offline.',
			'errors.not_found' => 'Not found.',
			'bookmarks.title' => 'Saved',
			'bookmarks.empty' => 'Nothing saved yet. Tap save on an entry to keep it for later.',
			'event.sources' => 'Sources',
			'event.people' => 'People',
			'event.source_classical' => 'classical',
			'event.source_primary' => 'primary',
			'event.source_modern' => 'modern',
			'event.weight_primary' => 'primary',
			'event.weight_notable' => 'notable',
			'event.weight_minority' => 'minority',
			'event.disputed_drawer_title' => 'Attested positions',
			'event.disputed_drawer_intro' => 'Classical Sunni sources disagree on this point. The positions are listed in order of attestation.',
			'person.eyebrow' => 'Person',
			'person.biography' => 'Biography',
			'person.restricted_prophet' => 'Out of reverence, no image of the Prophets ﷺ is shown.',
			'person.restricted_sahabi' => 'By policy, no AI-generated image of a Sahabi is shown.',
			'person.restricted_ahl_al_bayt' => 'By policy, no AI-generated image of the Ahl al-Bayt is shown.',
			'about.nav_label' => 'About',
			'about.title' => 'About the project · About me',
			'about.subtitle' => 'A few words on what this is, who built it, and how to reach out.',
			'about.name' => 'Souhib Trabelsi',
			'about.role' => 'Software engineer',
			'about.bio' => 'I\'m a software engineer with seven years of experience, mostly in Python and React. I started Thaqafa because I wanted a daily reading habit anchored in classical Islamic history. Every entry is hand-verified against official sources before it ships.',
			'about.project_purpose_title' => 'What is Thaqafa?',
			'about.project_purpose_body' => 'A verified event from Islamic history every day, in both Hijri and Gregorian calendars. Every entry — event, lesson, sacred day — is hand-verified against classical sources (al-Ṭabarī, Ibn Kathīr, the Six Books) before it\'s published. We drop a borderline entry rather than keep a wrong one. The promise is unconditional: every entry has been editorially reviewed.',
			'about.education_title' => 'Education',
			'about.education_epitech' => 'Epitech Paris — Master\'s in Software Engineering',
			'about.education_sfsu' => 'San Francisco State University — Certificate',
			'about.experience_title' => 'Experience',
			'about.experience_madura_title' => 'Madura Capital Management — Python Developer / DevOps',
			'about.experience_madura_period' => 'September 2024 — present',
			'about.experience_madura_desc' => 'Internal tooling for a hedge fund — data feeders, Prefect ETL pipelines, React/TypeScript trading UI.',
			'about.experience_snap_title' => 'Snapchat (SnapLab) — Python Developer / DevOps / AWS',
			'about.experience_snap_period' => 'May 2022 — September 2024',
			'about.experience_snap_desc' => 'Session-recording dashboard for Snap\'s Connected Spectacles team. FastAPI backend on AWS ECS via Terraform; React frontend.',
			'about.experience_enedis_title' => 'Enedis (EDF) — Python Developer / DevOps / Cloud',
			'about.experience_enedis_period' => 'April 2021 — April 2022',
			'about.experience_enedis_desc' => 'Customer-request platform with chat. FastAPI on AWS Lambda (Serverless framework); React/TypeScript frontend.',
			'about.experience_bnp_title' => 'BNP Paribas Personal Finance — Python Developer / DevOps',
			'about.experience_bnp_period' => 'September 2019 — March 2021',
			'about.experience_bnp_desc' => 'Migrated monolith to microservices. Python APIs giving data scientists secure access to large datasets via NAS-backed IDE sessions.',
			'about.experience_cloudeasier_title' => 'Cloudeasier (Accenture) — Python / Cloud Developer',
			'about.experience_cloudeasier_period' => 'February 2019 — August 2019',
			'about.experience_cloudeasier_desc' => 'Python on AWS Lambda + GCP Cloud Functions for compute pricing and scheduling. Terraform-deployed.',
			'about.skills_title' => 'Skills',
			'about.other_projects_title' => 'Other projects',
			'about.other_projects_majlisna_title' => 'Majlisna',
			'about.other_projects_majlisna_desc' => 'A real-time multiplayer party-game platform with Islamized variants of Undercover and Codenames.',
			'about.other_projects_majlisna_link' => 'majlisna.app',
			'about.other_projects_latabdhir_title' => 'LaTabdhir',
			'about.other_projects_latabdhir_desc' => 'A dhikr counter built around daily reminders and streaks.',
			'about.other_projects_latabdhir_link' => 'latabdhir.ae',
			'about.mentoring_title' => 'Free mentoring',
			'about.mentoring_body' => 'With my experience I can help CS engineers, developers, or anyone who wants to learn more about computer science — freely. I can also help with your resume, understanding the job market, preparing for interviews, or giving general advice when looking for jobs. Contact me via email or phone. If I don\'t answer, leave a message and I\'ll call you back.',
			'about.charity_title' => 'Support the Ummah',
			'about.charity_subtitle' => 'If this project is useful to you, please consider a donation to one of these.',
			'about.charity_human_appeal_desc' => 'International humanitarian charity working in conflict zones, food security, and orphan support.',
			'about.charity_ummah_charity_desc' => 'Long-running French charity active in education, water access, and emergency relief.',
			'about.charity_donate' => 'Donate',
			'about.contact_title' => 'Get in touch',
			'about.contact_email' => 'Email',
			'about.contact_phone' => 'Phone',
			'about.contact_linkedin' => 'LinkedIn',
			'about.contact_github' => 'GitHub',
			'about.quran_attribution_title' => 'Qur\'an editions',
			'about.quran_attribution_body' => 'Arabic text from Tanzil\'s ʿUthmānī Mushaf. English translation by Saheeh International. French translation by Muḥammad Hamidullah. The verse rendered above the footer is selected from the day\'s event citations when available, with Sūrat Yūsuf 12:111 — "there is a lesson for those of understanding" — as the standing fallback.',
			'about.created_by' => 'Created by',
			'auth.account' => 'Account',
			'auth.sign_in' => 'Sign in',
			'auth.sign_up' => 'Create account',
			'auth.sign_out' => 'Sign out',
			'auth.sign_in_title' => 'Welcome back.',
			'auth.sign_up_title' => 'Create an account.',
			'auth.email' => 'Email',
			'auth.password' => 'Password',
			'auth.display_name' => 'Display name',
			'auth.no_account_cta' => 'No account? Create one',
			'auth.have_account_cta' => 'Already have an account? Sign in',
			'auth.delete_account_cta' => 'Delete account',
			'auth.delete_account_title' => 'Delete account?',
			'auth.delete_account_warning' => 'This permanently removes your account and every saved bookmark. The action cannot be undone.',
			'auth.delete_account_cancel' => 'Cancel',
			'auth.delete_account_confirm' => 'Delete forever',
			'legal.title' => 'Legal',
			'legal.privacy' => 'Privacy Policy',
			'legal.terms' => 'Terms of Service',
			_ => null,
		};
	}
}

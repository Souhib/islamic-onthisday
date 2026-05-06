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
	late final TranslationsEventEn event = TranslationsEventEn._(_root);
	late final TranslationsPersonEn person = TranslationsPersonEn._(_root);
	late final TranslationsAboutEn about = TranslationsAboutEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Islamic On This Day'
	String get name => 'Islamic On This Day';

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

	/// en: 'Daily notification'
	String get notifications => 'Daily notification';

	/// en: 'Notification time'
	String get notification_time => 'Notification time';

	/// en: 'Today on the calendar'
	String get notification_title => 'Today on the calendar';

	/// en: 'A new entry awaits. Open to read.'
	String get notification_body => 'A new entry awaits. Open to read.';

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

	/// en: 'Created by'
	String get created_by => 'Created by';

	/// en: 'The classical record, one day at a time.'
	String get headline => 'The classical record, one day at a time.';

	/// en: 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.'
	String get intro => 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.';

	/// en: 'Other work'
	String get other_projects => 'Other work';

	/// en: 'Salons & gatherings — playful learning.'
	String get majlisna_subtitle => 'Salons & gatherings — playful learning.';

	/// en: 'Surplus food, redistributed.'
	String get latabdhir_subtitle => 'Surplus food, redistributed.';

	/// en: 'Contact'
	String get contact => 'Contact';

	/// en: 'Qur'an editions'
	String get editions_title => 'Qur\'an editions';

	/// en: 'Arabic text'
	String get edition_arabic_label => 'Arabic text';

	/// en: 'ʿUthmānī Mushaf — Tanzil'
	String get edition_arabic_value => 'ʿUthmānī Mushaf — Tanzil';

	/// en: 'English translation'
	String get edition_english_label => 'English translation';

	/// en: 'Saheeh International'
	String get edition_english_value => 'Saheeh International';

	/// en: 'French translation'
	String get edition_french_label => 'French translation';

	/// en: 'Muḥammad Hamidullah'
	String get edition_french_value => 'Muḥammad Hamidullah';
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
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Islamic On This Day',
			'app.tagline' => 'The classical record. One day at a time.',
			'onboarding.eyebrow' => 'In our time of days',
			'onboarding.headline' => 'The classical record,\none day at a time.',
			'onboarding.subhead' => 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.',
			'onboarding.begin' => 'Begin',
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
			'settings.notifications' => 'Daily notification',
			'settings.notification_time' => 'Notification time',
			'settings.notification_title' => 'Today on the calendar',
			'settings.notification_body' => 'A new entry awaits. Open to read.',
			'settings.about' => 'About',
			'errors.generic' => 'Something went wrong.',
			'errors.offline' => 'You appear to be offline.',
			'errors.not_found' => 'Not found.',
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
			'about.created_by' => 'Created by',
			'about.headline' => 'The classical record, one day at a time.',
			'about.intro' => 'Verified events from the 1,400-year arc of Islamic history. Every entry rooted in classical sources, every disputed date preserved.',
			'about.other_projects' => 'Other work',
			'about.majlisna_subtitle' => 'Salons & gatherings — playful learning.',
			'about.latabdhir_subtitle' => 'Surplus food, redistributed.',
			'about.contact' => 'Contact',
			'about.editions_title' => 'Qur\'an editions',
			'about.edition_arabic_label' => 'Arabic text',
			'about.edition_arabic_value' => 'ʿUthmānī Mushaf — Tanzil',
			'about.edition_english_label' => 'English translation',
			'about.edition_english_value' => 'Saheeh International',
			'about.edition_french_label' => 'French translation',
			'about.edition_french_value' => 'Muḥammad Hamidullah',
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
			_ => null,
		};
	}
}

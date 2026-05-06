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
}

// Path: verification
class TranslationsVerificationEn {
	TranslationsVerificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'scholar reviewed'
	String get scholar_reviewed => 'scholar reviewed';

	/// en: 'cross-verified'
	String get cross_verified => 'cross-verified';

	/// en: 'single source'
	String get single_source => 'single source';

	/// en: 'unverified'
	String get unverified => 'unverified';
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
			'verification.scholar_reviewed' => 'scholar reviewed',
			'verification.cross_verified' => 'cross-verified',
			'verification.single_source' => 'single source',
			'verification.unverified' => 'unverified',
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
			_ => null,
		};
	}
}

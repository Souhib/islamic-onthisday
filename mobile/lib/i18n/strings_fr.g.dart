///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsFr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsFr _root = this; // ignore: unused_field

	@override 
	TranslationsFr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppFr app = _TranslationsAppFr._(_root);
	@override late final _TranslationsOnboardingFr onboarding = _TranslationsOnboardingFr._(_root);
	@override late final _TranslationsTodayFr today = _TranslationsTodayFr._(_root);
	@override late final _TranslationsVerificationFr verification = _TranslationsVerificationFr._(_root);
	@override late final _TranslationsDisputeFr dispute = _TranslationsDisputeFr._(_root);
	@override late final _TranslationsNavFr nav = _TranslationsNavFr._(_root);
	@override late final _TranslationsSettingsFr settings = _TranslationsSettingsFr._(_root);
	@override late final _TranslationsErrorsFr errors = _TranslationsErrorsFr._(_root);
}

// Path: app
class _TranslationsAppFr implements TranslationsAppEn {
	_TranslationsAppFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Islam Aujourd\'hui dans l\'Histoire';
	@override String get tagline => 'Le corpus classique. Jour après jour.';
}

// Path: onboarding
class _TranslationsOnboardingFr implements TranslationsOnboardingEn {
	_TranslationsOnboardingFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'À notre époque';
	@override String get headline => 'Le corpus classique,\njour après jour.';
	@override String get subhead => 'Des événements vérifiés sur les 1 400 ans de l\'histoire de l\'islam. Chaque entrée enracinée dans les sources classiques, chaque date contestée préservée.';
	@override String get begin => 'Commencer';
}

// Path: today
class _TranslationsTodayFr implements TranslationsTodayEn {
	_TranslationsTodayFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aujourd\'hui';
	@override String get loading => 'chargement';
	@override String get load_failed => 'Impossible de charger aujourd\'hui.';
	@override String get more_reading => 'Plus de lectures pour aujourd\'hui';
	@override String get introduction => 'Introduction';
	@override String get the_reading => 'La lecture';
	@override String get end_of_reading => 'Fin de la lecture du jour';
}

// Path: verification
class _TranslationsVerificationFr implements TranslationsVerificationEn {
	_TranslationsVerificationFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get scholar_reviewed => 'validé par un savant';
	@override String get cross_verified => 'vérifié par recoupement';
	@override String get single_source => 'une seule source';
	@override String get unverified => 'non vérifié';
}

// Path: dispute
class _TranslationsDisputeFr implements TranslationsDisputeEn {
	_TranslationsDisputeFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get date => 'date contestée';
	@override String get detail => 'détail contesté';
	@override String get interpretation => 'interprétation contestée';
}

// Path: nav
class _TranslationsNavFr implements TranslationsNavEn {
	_TranslationsNavFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get today => 'Aujourd\'hui';
	@override String get recent => 'Récents';
	@override String get observances => 'Jours sacrés';
	@override String get settings => 'Paramètres';
}

// Path: settings
class _TranslationsSettingsFr implements TranslationsSettingsEn {
	_TranslationsSettingsFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres';
	@override String get appearance => 'Apparence';
	@override String get theme_light => 'Clair';
	@override String get theme_dark => 'Sombre';
	@override String get theme_system => 'Système';
	@override String get language => 'Langue';
	@override String get notifications => 'Notification quotidienne';
	@override String get notification_time => 'Heure de notification';
	@override String get notification_title => 'Aujourd\'hui dans le calendrier';
	@override String get notification_body => 'Une nouvelle entrée vous attend. Ouvrez pour lire.';
	@override String get about => 'À propos';
}

// Path: errors
class _TranslationsErrorsFr implements TranslationsErrorsEn {
	_TranslationsErrorsFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get generic => 'Une erreur est survenue.';
	@override String get offline => 'Vous semblez hors ligne.';
	@override String get not_found => 'Introuvable.';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsFr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Islam Aujourd\'hui dans l\'Histoire',
			'app.tagline' => 'Le corpus classique. Jour après jour.',
			'onboarding.eyebrow' => 'À notre époque',
			'onboarding.headline' => 'Le corpus classique,\njour après jour.',
			'onboarding.subhead' => 'Des événements vérifiés sur les 1 400 ans de l\'histoire de l\'islam. Chaque entrée enracinée dans les sources classiques, chaque date contestée préservée.',
			'onboarding.begin' => 'Commencer',
			'today.title' => 'Aujourd\'hui',
			'today.loading' => 'chargement',
			'today.load_failed' => 'Impossible de charger aujourd\'hui.',
			'today.more_reading' => 'Plus de lectures pour aujourd\'hui',
			'today.introduction' => 'Introduction',
			'today.the_reading' => 'La lecture',
			'today.end_of_reading' => 'Fin de la lecture du jour',
			'verification.scholar_reviewed' => 'validé par un savant',
			'verification.cross_verified' => 'vérifié par recoupement',
			'verification.single_source' => 'une seule source',
			'verification.unverified' => 'non vérifié',
			'dispute.date' => 'date contestée',
			'dispute.detail' => 'détail contesté',
			'dispute.interpretation' => 'interprétation contestée',
			'nav.today' => 'Aujourd\'hui',
			'nav.recent' => 'Récents',
			'nav.observances' => 'Jours sacrés',
			'nav.settings' => 'Paramètres',
			'settings.title' => 'Paramètres',
			'settings.appearance' => 'Apparence',
			'settings.theme_light' => 'Clair',
			'settings.theme_dark' => 'Sombre',
			'settings.theme_system' => 'Système',
			'settings.language' => 'Langue',
			'settings.notifications' => 'Notification quotidienne',
			'settings.notification_time' => 'Heure de notification',
			'settings.notification_title' => 'Aujourd\'hui dans le calendrier',
			'settings.notification_body' => 'Une nouvelle entrée vous attend. Ouvrez pour lire.',
			'settings.about' => 'À propos',
			'errors.generic' => 'Une erreur est survenue.',
			'errors.offline' => 'Vous semblez hors ligne.',
			'errors.not_found' => 'Introuvable.',
			_ => null,
		};
	}
}

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
	@override late final _TranslationsBookmarksFr bookmarks = _TranslationsBookmarksFr._(_root);
	@override late final _TranslationsEventFr event = _TranslationsEventFr._(_root);
	@override late final _TranslationsPersonFr person = _TranslationsPersonFr._(_root);
	@override late final _TranslationsAboutFr about = _TranslationsAboutFr._(_root);
	@override late final _TranslationsAuthFr auth = _TranslationsAuthFr._(_root);
	@override late final _TranslationsLegalFr legal = _TranslationsLegalFr._(_root);
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
	@override String get skip => 'Passer';
	@override String get kContinue => 'Continuer';
	@override String get lang_eyebrow => 'Choisis ta langue';
	@override String get lang_headline => 'Lis dans ta langue.';
	@override String get lang_subhead => 'La lecture et ses sources sont traduites en français, anglais et arabe. Tu pourras changer plus tard depuis les paramètres.';
	@override String get lang_en => 'English';
	@override String get lang_fr => 'Français';
	@override String get lang_ar => 'العربية';
	@override String get size_eyebrow => 'Une lecture confortable';
	@override String get size_headline => 'Choisissez la taille qui vous convient.';
	@override String get size_subhead => 'Modifiable plus tard dans les Paramètres — ou pincez avec deux doigts pour zoomer n\'importe où dans l\'app.';
	@override String get size_preview => 'Le corpus classique, jour après jour. Chaque entrée est enracinée dans les sources sunnites classiques — al-Ṭabarī, Ibn Kathīr, les Six Livres. Lisez-la une fois par jour, posez un rappel discret, et laissez le calendrier vous ramener demain.';
	@override String get notif_eyebrow => 'Un moment quotidien';
	@override String get notif_headline => 'Un rappel discret,\nune fois par jour.';
	@override String get notif_subhead => 'Choisis l\'heure qui t\'arrange. Aucune autre notification, et tu peux désactiver à tout moment.';
	@override String get notif_enable => 'Notification quotidienne';
	@override String get notif_time => 'Heure du rappel';
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
	@override String get verify => 'Vérifier';
}

// Path: verification
class _TranslationsVerificationFr implements TranslationsVerificationEn {
	_TranslationsVerificationFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get scholar_reviewed => 'Validé par un savant';
	@override String get cross_verified => 'Plusieurs sources';
	@override String get single_source => 'Une source';
	@override String get unverified => 'Non vérifié';
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
	@override String get reading_size => 'Taille du texte';
	@override String get reading_size_s => 'P';
	@override String get reading_size_m => 'M';
	@override String get reading_size_l => 'G';
	@override String get reading_size_xl => 'TG';
	@override String get notifications => 'Notification quotidienne';
	@override String get notification_time => 'Heure de notification';
	@override String get notification_title => 'Aujourd\'hui dans le calendrier';
	@override String get notification_body => 'Une nouvelle entrée vous attend. Ouvrez pour lire.';
	@override String get notification_test => 'Envoyer une notification de test';
	@override String get notification_test_title => 'Thaqafa — test';
	@override String get notification_test_body => 'Si vous lisez ceci, les notifications fonctionnent.';
	@override String get notification_test_pending => 'Une notification de test arrivera dans environ cinq secondes.';
	@override String get notification_permission_warning => 'Les notifications sont activées dans l\'app mais bloquées par iOS. Ouvrez les Réglages système pour les autoriser.';
	@override String get notification_open_system_settings => 'Ouvrir les réglages système';
	@override String get observances_link => 'Parcourir les jours sacrés';
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

// Path: bookmarks
class _TranslationsBookmarksFr implements TranslationsBookmarksEn {
	_TranslationsBookmarksFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Enregistrés';
	@override String get empty => 'Rien d\'enregistré pour l\'instant. Tapez « enregistrer » sur une entrée pour la garder.';
}

// Path: event
class _TranslationsEventFr implements TranslationsEventEn {
	_TranslationsEventFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get sources => 'Sources';
	@override String get people => 'Personnes';
	@override String get source_classical => 'classique';
	@override String get source_primary => 'primaire';
	@override String get source_modern => 'moderne';
	@override String get weight_primary => 'principale';
	@override String get weight_notable => 'notable';
	@override String get weight_minority => 'minoritaire';
	@override String get disputed_drawer_title => 'Positions attestées';
	@override String get disputed_drawer_intro => 'Les sources classiques sunnites divergent sur ce point. Les positions sont listées par ordre d\'attestation.';
}

// Path: person
class _TranslationsPersonFr implements TranslationsPersonEn {
	_TranslationsPersonFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'Personne';
	@override String get biography => 'Biographie';
	@override String get restricted_prophet => 'Par révérence, aucune image des Prophètes ﷺ n\'est affichée.';
	@override String get restricted_sahabi => 'Par principe, aucune image générée par IA d\'un Compagnon n\'est affichée.';
	@override String get restricted_ahl_al_bayt => 'Par principe, aucune image générée par IA des Ahl al-Bayt n\'est affichée.';
}

// Path: about
class _TranslationsAboutFr implements TranslationsAboutEn {
	_TranslationsAboutFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get nav_label => 'À propos';
	@override String get title => 'À propos du projet · À mon sujet';
	@override String get subtitle => 'Quelques mots sur ce qu\'est ce site, qui l\'a construit, et comment me joindre.';
	@override String get name => 'Souhib Trabelsi';
	@override String get role => 'Ingénieur logiciel';
	@override String get bio => 'Ingénieur logiciel avec sept ans d\'expérience, principalement en Python et React. J\'ai lancé Thaqafa parce que je voulais une habitude de lecture quotidienne ancrée dans l\'histoire islamique classique. Chaque entrée est vérifiée à la main contre des sources officielles avant publication.';
	@override String get project_purpose_title => 'Qu\'est-ce qu\'Thaqafa ?';
	@override String get project_purpose_body => 'Un événement vérifié de l\'histoire islamique chaque jour, en calendrier hégirien et grégorien. Chaque entrée — événement, leçon, jour sacré — est vérifiée à la main contre des sources classiques officielles (al-Ṭabarī, Ibn Kathīr, les Six Livres) avant d\'être publiée. On retire une entrée douteuse plutôt que d\'en garder une fausse. La promesse est inconditionnelle : chaque entrée a été éditorialement révisée.';
	@override String get education_title => 'Formation';
	@override String get education_epitech => 'Epitech Paris — Master en ingénierie logicielle';
	@override String get education_sfsu => 'San Francisco State University — Certificate';
	@override String get experience_title => 'Expérience';
	@override String get experience_madura_title => 'Madura Capital Management — Développeur Python / DevOps';
	@override String get experience_madura_period => 'Septembre 2024 — aujourd\'hui';
	@override String get experience_madura_desc => 'Outillage interne pour un hedge fund — feeders de données, pipelines ETL Prefect, interface de trading React/TypeScript.';
	@override String get experience_snap_title => 'Snapchat (SnapLab) — Développeur Python / DevOps / AWS';
	@override String get experience_snap_period => 'Mai 2022 — Septembre 2024';
	@override String get experience_snap_desc => 'Tableau de bord d\'enregistrement de sessions pour l\'équipe Connected Spectacles de Snap. Backend FastAPI sur AWS ECS via Terraform ; front React.';
	@override String get experience_enedis_title => 'Enedis (EDF) — Développeur Python / DevOps / Cloud';
	@override String get experience_enedis_period => 'Avril 2021 — Avril 2022';
	@override String get experience_enedis_desc => 'Plateforme de suivi des demandes clients avec chat. FastAPI sur AWS Lambda (Serverless) ; front React/TypeScript.';
	@override String get experience_bnp_title => 'BNP Paribas Personal Finance — Développeur Python / DevOps';
	@override String get experience_bnp_period => 'Septembre 2019 — Mars 2021';
	@override String get experience_bnp_desc => 'Migration d\'un monolithe vers des microservices. APIs Python permettant aux data scientists d\'accéder à de gros datasets via NAS dans des sessions IDE sécurisées.';
	@override String get experience_cloudeasier_title => 'Cloudeasier (Accenture) — Développeur Python / Cloud';
	@override String get experience_cloudeasier_period => 'Février 2019 — Août 2019';
	@override String get experience_cloudeasier_desc => 'Python sur AWS Lambda + GCP Cloud Functions pour la tarification compute et la planification. Déploiement Terraform.';
	@override String get skills_title => 'Compétences';
	@override String get other_projects_title => 'Autres projets';
	@override String get other_projects_majlisna_title => 'Majlisna';
	@override String get other_projects_majlisna_desc => 'Plateforme de jeux multijoueurs en temps réel avec des variantes islamisées d\'Undercover et Codenames.';
	@override String get other_projects_majlisna_link => 'majlisna.app';
	@override String get other_projects_latabdhir_title => 'LaTabdhir';
	@override String get other_projects_latabdhir_desc => 'Compteur de dhikr conçu autour de rappels quotidiens et de séries.';
	@override String get other_projects_latabdhir_link => 'latabdhir.ae';
	@override String get mentoring_title => 'Mentorat gratuit';
	@override String get mentoring_body => 'Avec mon expérience, je peux aider les ingénieurs en informatique, les développeurs, ou toute personne souhaitant en apprendre davantage sur l\'informatique — gratuitement. Je peux aussi aider à rédiger ou améliorer votre CV, comprendre le marché de l\'emploi, préparer vos entretiens ou donner des conseils généraux pour votre recherche d\'emploi. Contactez-moi par e-mail ou téléphone. Si je ne réponds pas, laissez un message et je vous rappellerai.';
	@override String get charity_title => 'Soutenir l\'Oumma';
	@override String get charity_subtitle => 'Si ce projet vous est utile, pensez à faire un don à l\'une de ces associations.';
	@override String get charity_human_appeal_desc => 'Association humanitaire internationale active dans les zones de conflit, la sécurité alimentaire et le soutien aux orphelins.';
	@override String get charity_ummah_charity_desc => 'Association française historique active dans l\'éducation, l\'accès à l\'eau et l\'aide d\'urgence.';
	@override String get charity_donate => 'Faire un don';
	@override String get contact_title => 'Me contacter';
	@override String get contact_email => 'Email';
	@override String get contact_phone => 'Téléphone';
	@override String get contact_linkedin => 'LinkedIn';
	@override String get contact_github => 'GitHub';
	@override String get quran_attribution_title => 'Éditions du Coran';
	@override String get quran_attribution_body => 'Texte arabe d\'après le Mushaf ʿUthmānī de Tanzil. Traduction anglaise de Saheeh International. Traduction française de Muḥammad Hamidullah. Le verset affiché au-dessus du footer est choisi parmi les citations de l\'événement du jour lorsqu\'elles existent ; sinon Sourate Yūsuf 12:111 — « il y a certes une leçon pour les gens doués d\'intelligence » — sert d\'épigraphe permanente.';
	@override String get created_by => 'Créé par';
}

// Path: auth
class _TranslationsAuthFr implements TranslationsAuthEn {
	_TranslationsAuthFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get account => 'Compte';
	@override String get sign_in => 'Se connecter';
	@override String get sign_up => 'Créer un compte';
	@override String get sign_out => 'Se déconnecter';
	@override String get sign_in_title => 'Bon retour.';
	@override String get sign_up_title => 'Créer un compte.';
	@override String get email => 'E-mail';
	@override String get password => 'Mot de passe';
	@override String get display_name => 'Nom affiché';
	@override String get no_account_cta => 'Pas de compte ? En créer un';
	@override String get have_account_cta => 'Déjà un compte ? Se connecter';
	@override String get delete_account_cta => 'Supprimer le compte';
	@override String get delete_account_title => 'Supprimer le compte ?';
	@override String get delete_account_warning => 'Cette action supprime définitivement votre compte et tous les bookmarks enregistrés. Elle est irréversible.';
	@override String get delete_account_cancel => 'Annuler';
	@override String get delete_account_confirm => 'Supprimer définitivement';
}

// Path: legal
class _TranslationsLegalFr implements TranslationsLegalEn {
	_TranslationsLegalFr._(this._root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mentions légales';
	@override String get privacy => 'Politique de confidentialité';
	@override String get terms => 'Conditions d\'utilisation';
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
			'onboarding.skip' => 'Passer',
			'onboarding.kContinue' => 'Continuer',
			'onboarding.lang_eyebrow' => 'Choisis ta langue',
			'onboarding.lang_headline' => 'Lis dans ta langue.',
			'onboarding.lang_subhead' => 'La lecture et ses sources sont traduites en français, anglais et arabe. Tu pourras changer plus tard depuis les paramètres.',
			'onboarding.lang_en' => 'English',
			'onboarding.lang_fr' => 'Français',
			'onboarding.lang_ar' => 'العربية',
			'onboarding.size_eyebrow' => 'Une lecture confortable',
			'onboarding.size_headline' => 'Choisissez la taille qui vous convient.',
			'onboarding.size_subhead' => 'Modifiable plus tard dans les Paramètres — ou pincez avec deux doigts pour zoomer n\'importe où dans l\'app.',
			'onboarding.size_preview' => 'Le corpus classique, jour après jour. Chaque entrée est enracinée dans les sources sunnites classiques — al-Ṭabarī, Ibn Kathīr, les Six Livres. Lisez-la une fois par jour, posez un rappel discret, et laissez le calendrier vous ramener demain.',
			'onboarding.notif_eyebrow' => 'Un moment quotidien',
			'onboarding.notif_headline' => 'Un rappel discret,\nune fois par jour.',
			'onboarding.notif_subhead' => 'Choisis l\'heure qui t\'arrange. Aucune autre notification, et tu peux désactiver à tout moment.',
			'onboarding.notif_enable' => 'Notification quotidienne',
			'onboarding.notif_time' => 'Heure du rappel',
			'today.title' => 'Aujourd\'hui',
			'today.loading' => 'chargement',
			'today.load_failed' => 'Impossible de charger aujourd\'hui.',
			'today.more_reading' => 'Plus de lectures pour aujourd\'hui',
			'today.introduction' => 'Introduction',
			'today.the_reading' => 'La lecture',
			'today.end_of_reading' => 'Fin de la lecture du jour',
			'today.verify' => 'Vérifier',
			'verification.scholar_reviewed' => 'Validé par un savant',
			'verification.cross_verified' => 'Plusieurs sources',
			'verification.single_source' => 'Une source',
			'verification.unverified' => 'Non vérifié',
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
			'settings.reading_size' => 'Taille du texte',
			'settings.reading_size_s' => 'P',
			'settings.reading_size_m' => 'M',
			'settings.reading_size_l' => 'G',
			'settings.reading_size_xl' => 'TG',
			'settings.notifications' => 'Notification quotidienne',
			'settings.notification_time' => 'Heure de notification',
			'settings.notification_title' => 'Aujourd\'hui dans le calendrier',
			'settings.notification_body' => 'Une nouvelle entrée vous attend. Ouvrez pour lire.',
			'settings.notification_test' => 'Envoyer une notification de test',
			'settings.notification_test_title' => 'Thaqafa — test',
			'settings.notification_test_body' => 'Si vous lisez ceci, les notifications fonctionnent.',
			'settings.notification_test_pending' => 'Une notification de test arrivera dans environ cinq secondes.',
			'settings.notification_permission_warning' => 'Les notifications sont activées dans l\'app mais bloquées par iOS. Ouvrez les Réglages système pour les autoriser.',
			'settings.notification_open_system_settings' => 'Ouvrir les réglages système',
			'settings.observances_link' => 'Parcourir les jours sacrés',
			'settings.about' => 'À propos',
			'errors.generic' => 'Une erreur est survenue.',
			'errors.offline' => 'Vous semblez hors ligne.',
			'errors.not_found' => 'Introuvable.',
			'bookmarks.title' => 'Enregistrés',
			'bookmarks.empty' => 'Rien d\'enregistré pour l\'instant. Tapez « enregistrer » sur une entrée pour la garder.',
			'event.sources' => 'Sources',
			'event.people' => 'Personnes',
			'event.source_classical' => 'classique',
			'event.source_primary' => 'primaire',
			'event.source_modern' => 'moderne',
			'event.weight_primary' => 'principale',
			'event.weight_notable' => 'notable',
			'event.weight_minority' => 'minoritaire',
			'event.disputed_drawer_title' => 'Positions attestées',
			'event.disputed_drawer_intro' => 'Les sources classiques sunnites divergent sur ce point. Les positions sont listées par ordre d\'attestation.',
			'person.eyebrow' => 'Personne',
			'person.biography' => 'Biographie',
			'person.restricted_prophet' => 'Par révérence, aucune image des Prophètes ﷺ n\'est affichée.',
			'person.restricted_sahabi' => 'Par principe, aucune image générée par IA d\'un Compagnon n\'est affichée.',
			'person.restricted_ahl_al_bayt' => 'Par principe, aucune image générée par IA des Ahl al-Bayt n\'est affichée.',
			'about.nav_label' => 'À propos',
			'about.title' => 'À propos du projet · À mon sujet',
			'about.subtitle' => 'Quelques mots sur ce qu\'est ce site, qui l\'a construit, et comment me joindre.',
			'about.name' => 'Souhib Trabelsi',
			'about.role' => 'Ingénieur logiciel',
			'about.bio' => 'Ingénieur logiciel avec sept ans d\'expérience, principalement en Python et React. J\'ai lancé Thaqafa parce que je voulais une habitude de lecture quotidienne ancrée dans l\'histoire islamique classique. Chaque entrée est vérifiée à la main contre des sources officielles avant publication.',
			'about.project_purpose_title' => 'Qu\'est-ce qu\'Thaqafa ?',
			'about.project_purpose_body' => 'Un événement vérifié de l\'histoire islamique chaque jour, en calendrier hégirien et grégorien. Chaque entrée — événement, leçon, jour sacré — est vérifiée à la main contre des sources classiques officielles (al-Ṭabarī, Ibn Kathīr, les Six Livres) avant d\'être publiée. On retire une entrée douteuse plutôt que d\'en garder une fausse. La promesse est inconditionnelle : chaque entrée a été éditorialement révisée.',
			'about.education_title' => 'Formation',
			'about.education_epitech' => 'Epitech Paris — Master en ingénierie logicielle',
			'about.education_sfsu' => 'San Francisco State University — Certificate',
			'about.experience_title' => 'Expérience',
			'about.experience_madura_title' => 'Madura Capital Management — Développeur Python / DevOps',
			'about.experience_madura_period' => 'Septembre 2024 — aujourd\'hui',
			'about.experience_madura_desc' => 'Outillage interne pour un hedge fund — feeders de données, pipelines ETL Prefect, interface de trading React/TypeScript.',
			'about.experience_snap_title' => 'Snapchat (SnapLab) — Développeur Python / DevOps / AWS',
			'about.experience_snap_period' => 'Mai 2022 — Septembre 2024',
			'about.experience_snap_desc' => 'Tableau de bord d\'enregistrement de sessions pour l\'équipe Connected Spectacles de Snap. Backend FastAPI sur AWS ECS via Terraform ; front React.',
			'about.experience_enedis_title' => 'Enedis (EDF) — Développeur Python / DevOps / Cloud',
			'about.experience_enedis_period' => 'Avril 2021 — Avril 2022',
			'about.experience_enedis_desc' => 'Plateforme de suivi des demandes clients avec chat. FastAPI sur AWS Lambda (Serverless) ; front React/TypeScript.',
			'about.experience_bnp_title' => 'BNP Paribas Personal Finance — Développeur Python / DevOps',
			'about.experience_bnp_period' => 'Septembre 2019 — Mars 2021',
			'about.experience_bnp_desc' => 'Migration d\'un monolithe vers des microservices. APIs Python permettant aux data scientists d\'accéder à de gros datasets via NAS dans des sessions IDE sécurisées.',
			'about.experience_cloudeasier_title' => 'Cloudeasier (Accenture) — Développeur Python / Cloud',
			'about.experience_cloudeasier_period' => 'Février 2019 — Août 2019',
			'about.experience_cloudeasier_desc' => 'Python sur AWS Lambda + GCP Cloud Functions pour la tarification compute et la planification. Déploiement Terraform.',
			'about.skills_title' => 'Compétences',
			'about.other_projects_title' => 'Autres projets',
			'about.other_projects_majlisna_title' => 'Majlisna',
			'about.other_projects_majlisna_desc' => 'Plateforme de jeux multijoueurs en temps réel avec des variantes islamisées d\'Undercover et Codenames.',
			'about.other_projects_majlisna_link' => 'majlisna.app',
			'about.other_projects_latabdhir_title' => 'LaTabdhir',
			'about.other_projects_latabdhir_desc' => 'Compteur de dhikr conçu autour de rappels quotidiens et de séries.',
			'about.other_projects_latabdhir_link' => 'latabdhir.ae',
			'about.mentoring_title' => 'Mentorat gratuit',
			'about.mentoring_body' => 'Avec mon expérience, je peux aider les ingénieurs en informatique, les développeurs, ou toute personne souhaitant en apprendre davantage sur l\'informatique — gratuitement. Je peux aussi aider à rédiger ou améliorer votre CV, comprendre le marché de l\'emploi, préparer vos entretiens ou donner des conseils généraux pour votre recherche d\'emploi. Contactez-moi par e-mail ou téléphone. Si je ne réponds pas, laissez un message et je vous rappellerai.',
			'about.charity_title' => 'Soutenir l\'Oumma',
			'about.charity_subtitle' => 'Si ce projet vous est utile, pensez à faire un don à l\'une de ces associations.',
			'about.charity_human_appeal_desc' => 'Association humanitaire internationale active dans les zones de conflit, la sécurité alimentaire et le soutien aux orphelins.',
			'about.charity_ummah_charity_desc' => 'Association française historique active dans l\'éducation, l\'accès à l\'eau et l\'aide d\'urgence.',
			'about.charity_donate' => 'Faire un don',
			'about.contact_title' => 'Me contacter',
			'about.contact_email' => 'Email',
			'about.contact_phone' => 'Téléphone',
			'about.contact_linkedin' => 'LinkedIn',
			'about.contact_github' => 'GitHub',
			'about.quran_attribution_title' => 'Éditions du Coran',
			'about.quran_attribution_body' => 'Texte arabe d\'après le Mushaf ʿUthmānī de Tanzil. Traduction anglaise de Saheeh International. Traduction française de Muḥammad Hamidullah. Le verset affiché au-dessus du footer est choisi parmi les citations de l\'événement du jour lorsqu\'elles existent ; sinon Sourate Yūsuf 12:111 — « il y a certes une leçon pour les gens doués d\'intelligence » — sert d\'épigraphe permanente.',
			'about.created_by' => 'Créé par',
			'auth.account' => 'Compte',
			'auth.sign_in' => 'Se connecter',
			'auth.sign_up' => 'Créer un compte',
			'auth.sign_out' => 'Se déconnecter',
			'auth.sign_in_title' => 'Bon retour.',
			'auth.sign_up_title' => 'Créer un compte.',
			'auth.email' => 'E-mail',
			'auth.password' => 'Mot de passe',
			'auth.display_name' => 'Nom affiché',
			'auth.no_account_cta' => 'Pas de compte ? En créer un',
			'auth.have_account_cta' => 'Déjà un compte ? Se connecter',
			'auth.delete_account_cta' => 'Supprimer le compte',
			'auth.delete_account_title' => 'Supprimer le compte ?',
			'auth.delete_account_warning' => 'Cette action supprime définitivement votre compte et tous les bookmarks enregistrés. Elle est irréversible.',
			'auth.delete_account_cancel' => 'Annuler',
			'auth.delete_account_confirm' => 'Supprimer définitivement',
			'legal.title' => 'Mentions légales',
			'legal.privacy' => 'Politique de confidentialité',
			'legal.terms' => 'Conditions d\'utilisation',
			_ => null,
		};
	}
}

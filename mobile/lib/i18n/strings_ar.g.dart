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
class TranslationsAr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsAr _root = this; // ignore: unused_field

	@override 
	TranslationsAr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsAr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppAr app = _TranslationsAppAr._(_root);
	@override late final _TranslationsOnboardingAr onboarding = _TranslationsOnboardingAr._(_root);
	@override late final _TranslationsTodayAr today = _TranslationsTodayAr._(_root);
	@override late final _TranslationsVerificationAr verification = _TranslationsVerificationAr._(_root);
	@override late final _TranslationsDisputeAr dispute = _TranslationsDisputeAr._(_root);
	@override late final _TranslationsNavAr nav = _TranslationsNavAr._(_root);
	@override late final _TranslationsSettingsAr settings = _TranslationsSettingsAr._(_root);
	@override late final _TranslationsErrorsAr errors = _TranslationsErrorsAr._(_root);
	@override late final _TranslationsEventAr event = _TranslationsEventAr._(_root);
	@override late final _TranslationsPersonAr person = _TranslationsPersonAr._(_root);
	@override late final _TranslationsAboutAr about = _TranslationsAboutAr._(_root);
	@override late final _TranslationsAuthAr auth = _TranslationsAuthAr._(_root);
}

// Path: app
class _TranslationsAppAr implements TranslationsAppEn {
	_TranslationsAppAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get name => 'الإسلام في هذا اليوم';
	@override String get tagline => 'السجل الكلاسيكي. يومًا بعد يوم.';
}

// Path: onboarding
class _TranslationsOnboardingAr implements TranslationsOnboardingEn {
	_TranslationsOnboardingAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'في زماننا';
	@override String get headline => 'السجل الكلاسيكي،\nيومًا بعد يوم.';
	@override String get subhead => 'أحداث موثّقة من قوس التاريخ الإسلامي الممتد لأربعة عشر قرنًا. كلّ مدخل متجذّر في المصادر الكلاسيكية، وكلّ تاريخ متنازع عليه محفوظ.';
	@override String get begin => 'ابدأ';
}

// Path: today
class _TranslationsTodayAr implements TranslationsTodayEn {
	_TranslationsTodayAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'اليوم';
	@override String get loading => 'جارٍ التحميل';
	@override String get load_failed => 'تعذّر تحميل اليوم.';
	@override String get more_reading => 'قراءات إضافية لهذا اليوم';
	@override String get introduction => 'مقدّمة';
	@override String get the_reading => 'القراءة';
	@override String get end_of_reading => 'نهاية قراءة اليوم';
	@override String get verify => 'تحقّق';
}

// Path: verification
class _TranslationsVerificationAr implements TranslationsVerificationEn {
	_TranslationsVerificationAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get scholar_reviewed => 'مراجَعة علمية';
	@override String get cross_verified => 'متحقَّق منها بمصادر متعددة';
	@override String get single_source => 'مصدر واحد';
	@override String get unverified => 'غير محقَّق';
}

// Path: dispute
class _TranslationsDisputeAr implements TranslationsDisputeEn {
	_TranslationsDisputeAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get date => 'تاريخ متنازع عليه';
	@override String get detail => 'تفصيل متنازع عليه';
	@override String get interpretation => 'تفسير متنازع عليه';
}

// Path: nav
class _TranslationsNavAr implements TranslationsNavEn {
	_TranslationsNavAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get today => 'اليوم';
	@override String get recent => 'الأحدث';
	@override String get observances => 'الأيام المباركة';
	@override String get settings => 'الإعدادات';
}

// Path: settings
class _TranslationsSettingsAr implements TranslationsSettingsEn {
	_TranslationsSettingsAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'الإعدادات';
	@override String get appearance => 'المظهر';
	@override String get theme_light => 'فاتح';
	@override String get theme_dark => 'داكن';
	@override String get theme_system => 'النظام';
	@override String get language => 'اللغة';
	@override String get notifications => 'إشعار يومي';
	@override String get notification_time => 'وقت الإشعار';
	@override String get notification_title => 'اليوم في التقويم';
	@override String get notification_body => 'مدخل جديد في انتظارك. افتح لتقرأ.';
	@override String get about => 'حول';
}

// Path: errors
class _TranslationsErrorsAr implements TranslationsErrorsEn {
	_TranslationsErrorsAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get generic => 'حدث خطأ ما.';
	@override String get offline => 'يبدو أنّك غير متّصل.';
	@override String get not_found => 'غير موجود.';
}

// Path: event
class _TranslationsEventAr implements TranslationsEventEn {
	_TranslationsEventAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get sources => 'المصادر';
	@override String get people => 'الشخصيات';
	@override String get source_classical => 'كلاسيكي';
	@override String get source_primary => 'أولي';
	@override String get source_modern => 'حديث';
	@override String get weight_primary => 'أساسي';
	@override String get weight_notable => 'ملحوظ';
	@override String get weight_minority => 'أقلية';
	@override String get disputed_drawer_title => 'الأقوال المنقولة';
	@override String get disputed_drawer_intro => 'اختلفت المصادر السنية الكلاسيكية في هذا الشأن. الأقوال مرتبة حسب الإثبات.';
}

// Path: person
class _TranslationsPersonAr implements TranslationsPersonEn {
	_TranslationsPersonAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'شخصية';
	@override String get biography => 'السيرة';
	@override String get restricted_prophet => 'احترامًا، لا تُعرض أيّ صورة للأنبياء ﷺ.';
	@override String get restricted_sahabi => 'بحسب السياسة، لا تُعرض أيّ صورة مولّدة بالذكاء الاصطناعي للصحابة.';
	@override String get restricted_ahl_al_bayt => 'بحسب السياسة، لا تُعرض أيّ صورة مولّدة بالذكاء الاصطناعي لأهل البيت.';
}

// Path: about
class _TranslationsAboutAr implements TranslationsAboutEn {
	_TranslationsAboutAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get created_by => 'من تأليف';
	@override String get headline => 'السجل الكلاسيكي، يومًا بعد يوم.';
	@override String get intro => 'أحداث موثّقة من قوس التاريخ الإسلامي الممتد لأربعة عشر قرنًا. كلّ مدخل متجذّر في المصادر الكلاسيكية، وكلّ تاريخ متنازع عليه محفوظ.';
	@override String get other_projects => 'أعمال أخرى';
	@override String get majlisna_subtitle => 'صالونات ومجالس — تعلّم بهيج.';
	@override String get latabdhir_subtitle => 'فائض الطعام، مُعاد توزيعه.';
	@override String get contact => 'تواصل';
	@override String get editions_title => 'إصدارات القرآن';
	@override String get edition_arabic_label => 'النصّ العربي';
	@override String get edition_arabic_value => 'المصحف العثماني — Tanzil';
	@override String get edition_english_label => 'الترجمة الإنجليزية';
	@override String get edition_english_value => 'Saheeh International';
	@override String get edition_french_label => 'الترجمة الفرنسية';
	@override String get edition_french_value => 'محمد حميد الله';
}

// Path: auth
class _TranslationsAuthAr implements TranslationsAuthEn {
	_TranslationsAuthAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get account => 'الحساب';
	@override String get sign_in => 'تسجيل الدخول';
	@override String get sign_up => 'إنشاء حساب';
	@override String get sign_out => 'تسجيل الخروج';
	@override String get sign_in_title => 'مرحبًا بعودتك.';
	@override String get sign_up_title => 'إنشاء حساب.';
	@override String get email => 'البريد الإلكتروني';
	@override String get password => 'كلمة المرور';
	@override String get display_name => 'الاسم المعروض';
	@override String get no_account_cta => 'ليس لديك حساب؟ أنشئ حسابًا';
	@override String get have_account_cta => 'لديك حساب بالفعل؟ سجّل الدخول';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsAr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'الإسلام في هذا اليوم',
			'app.tagline' => 'السجل الكلاسيكي. يومًا بعد يوم.',
			'onboarding.eyebrow' => 'في زماننا',
			'onboarding.headline' => 'السجل الكلاسيكي،\nيومًا بعد يوم.',
			'onboarding.subhead' => 'أحداث موثّقة من قوس التاريخ الإسلامي الممتد لأربعة عشر قرنًا. كلّ مدخل متجذّر في المصادر الكلاسيكية، وكلّ تاريخ متنازع عليه محفوظ.',
			'onboarding.begin' => 'ابدأ',
			'today.title' => 'اليوم',
			'today.loading' => 'جارٍ التحميل',
			'today.load_failed' => 'تعذّر تحميل اليوم.',
			'today.more_reading' => 'قراءات إضافية لهذا اليوم',
			'today.introduction' => 'مقدّمة',
			'today.the_reading' => 'القراءة',
			'today.end_of_reading' => 'نهاية قراءة اليوم',
			'today.verify' => 'تحقّق',
			'verification.scholar_reviewed' => 'مراجَعة علمية',
			'verification.cross_verified' => 'متحقَّق منها بمصادر متعددة',
			'verification.single_source' => 'مصدر واحد',
			'verification.unverified' => 'غير محقَّق',
			'dispute.date' => 'تاريخ متنازع عليه',
			'dispute.detail' => 'تفصيل متنازع عليه',
			'dispute.interpretation' => 'تفسير متنازع عليه',
			'nav.today' => 'اليوم',
			'nav.recent' => 'الأحدث',
			'nav.observances' => 'الأيام المباركة',
			'nav.settings' => 'الإعدادات',
			'settings.title' => 'الإعدادات',
			'settings.appearance' => 'المظهر',
			'settings.theme_light' => 'فاتح',
			'settings.theme_dark' => 'داكن',
			'settings.theme_system' => 'النظام',
			'settings.language' => 'اللغة',
			'settings.notifications' => 'إشعار يومي',
			'settings.notification_time' => 'وقت الإشعار',
			'settings.notification_title' => 'اليوم في التقويم',
			'settings.notification_body' => 'مدخل جديد في انتظارك. افتح لتقرأ.',
			'settings.about' => 'حول',
			'errors.generic' => 'حدث خطأ ما.',
			'errors.offline' => 'يبدو أنّك غير متّصل.',
			'errors.not_found' => 'غير موجود.',
			'event.sources' => 'المصادر',
			'event.people' => 'الشخصيات',
			'event.source_classical' => 'كلاسيكي',
			'event.source_primary' => 'أولي',
			'event.source_modern' => 'حديث',
			'event.weight_primary' => 'أساسي',
			'event.weight_notable' => 'ملحوظ',
			'event.weight_minority' => 'أقلية',
			'event.disputed_drawer_title' => 'الأقوال المنقولة',
			'event.disputed_drawer_intro' => 'اختلفت المصادر السنية الكلاسيكية في هذا الشأن. الأقوال مرتبة حسب الإثبات.',
			'person.eyebrow' => 'شخصية',
			'person.biography' => 'السيرة',
			'person.restricted_prophet' => 'احترامًا، لا تُعرض أيّ صورة للأنبياء ﷺ.',
			'person.restricted_sahabi' => 'بحسب السياسة، لا تُعرض أيّ صورة مولّدة بالذكاء الاصطناعي للصحابة.',
			'person.restricted_ahl_al_bayt' => 'بحسب السياسة، لا تُعرض أيّ صورة مولّدة بالذكاء الاصطناعي لأهل البيت.',
			'about.created_by' => 'من تأليف',
			'about.headline' => 'السجل الكلاسيكي، يومًا بعد يوم.',
			'about.intro' => 'أحداث موثّقة من قوس التاريخ الإسلامي الممتد لأربعة عشر قرنًا. كلّ مدخل متجذّر في المصادر الكلاسيكية، وكلّ تاريخ متنازع عليه محفوظ.',
			'about.other_projects' => 'أعمال أخرى',
			'about.majlisna_subtitle' => 'صالونات ومجالس — تعلّم بهيج.',
			'about.latabdhir_subtitle' => 'فائض الطعام، مُعاد توزيعه.',
			'about.contact' => 'تواصل',
			'about.editions_title' => 'إصدارات القرآن',
			'about.edition_arabic_label' => 'النصّ العربي',
			'about.edition_arabic_value' => 'المصحف العثماني — Tanzil',
			'about.edition_english_label' => 'الترجمة الإنجليزية',
			'about.edition_english_value' => 'Saheeh International',
			'about.edition_french_label' => 'الترجمة الفرنسية',
			'about.edition_french_value' => 'محمد حميد الله',
			'auth.account' => 'الحساب',
			'auth.sign_in' => 'تسجيل الدخول',
			'auth.sign_up' => 'إنشاء حساب',
			'auth.sign_out' => 'تسجيل الخروج',
			'auth.sign_in_title' => 'مرحبًا بعودتك.',
			'auth.sign_up_title' => 'إنشاء حساب.',
			'auth.email' => 'البريد الإلكتروني',
			'auth.password' => 'كلمة المرور',
			'auth.display_name' => 'الاسم المعروض',
			'auth.no_account_cta' => 'ليس لديك حساب؟ أنشئ حسابًا',
			'auth.have_account_cta' => 'لديك حساب بالفعل؟ سجّل الدخول',
			_ => null,
		};
	}
}

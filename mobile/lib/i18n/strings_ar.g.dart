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
	@override late final _TranslationsBookmarksAr bookmarks = _TranslationsBookmarksAr._(_root);
	@override late final _TranslationsEventAr event = _TranslationsEventAr._(_root);
	@override late final _TranslationsPersonAr person = _TranslationsPersonAr._(_root);
	@override late final _TranslationsAboutAr about = _TranslationsAboutAr._(_root);
	@override late final _TranslationsAuthAr auth = _TranslationsAuthAr._(_root);
	@override late final _TranslationsLegalAr legal = _TranslationsLegalAr._(_root);
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
	@override String get skip => 'تخطّى';
	@override String get kContinue => 'تابِع';
	@override String get lang_eyebrow => 'اختر لغتك';
	@override String get lang_headline => 'اقرأ بلغتك.';
	@override String get lang_subhead => 'القراءة ومصادرها مترجمة إلى العربية والإنجليزية والفرنسية. يمكنك التغيير لاحقًا من الإعدادات.';
	@override String get lang_en => 'English';
	@override String get lang_fr => 'Français';
	@override String get lang_ar => 'العربية';
	@override String get notif_eyebrow => 'موعد يومي';
	@override String get notif_headline => 'تذكير هادئ،\nمرّة في اليوم.';
	@override String get notif_subhead => 'اختر الساعة التي تناسبك. لا إشعارات أخرى، ويمكنك إيقاف هذا في أيّ وقت.';
	@override String get notif_enable => 'إشعار يومي';
	@override String get notif_time => 'وقت التذكير';
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
	@override String get scholar_reviewed => 'مراجَع علمياً';
	@override String get cross_verified => 'مصادر متعدّدة';
	@override String get single_source => 'مصدر واحد';
	@override String get unverified => 'غير محقّق';
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
	@override String get notification_test => 'إرسال إشعار تجريبي';
	@override String get notification_test_title => 'ثقافة — اختبار';
	@override String get notification_test_body => 'إذا قرأتَ هذا فالإشعارات تعمل.';
	@override String get notification_test_pending => 'سيصل إشعار تجريبي بعد خمس ثوانٍ تقريبًا.';
	@override String get notification_permission_warning => 'الإشعارات مُفعَّلة داخل التطبيق لكن نظام iOS يحجبها. افتح إعدادات النظام للسماح بها.';
	@override String get notification_open_system_settings => 'فتح إعدادات النظام';
	@override String get observances_link => 'تصفّح الأيام المُباركة';
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

// Path: bookmarks
class _TranslationsBookmarksAr implements TranslationsBookmarksEn {
	_TranslationsBookmarksAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'المحفوظات';
	@override String get empty => 'لم يُحفَظ شيء بعد. اضغط «حفظ» على مدخل لإبقائه.';
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
	@override String get nav_label => 'حولنا';
	@override String get title => 'حول المشروع · عنّي';
	@override String get subtitle => 'كلمات قليلة عن هذا الموقع، ومَن بناه، وكيف يمكن التواصل.';
	@override String get name => 'صهيب الطرابلسي';
	@override String get role => 'مهندس برمجيات';
	@override String get bio => 'مهندس برمجيات بسبع سنوات من الخبرة، أغلبها في Python وReact. أطلقتُ "Thaqafa" لأنّي أردتُ عادة قراءة يومية مرتكزة على التاريخ الإسلامي الكلاسيكي. كلّ مدخل مدقَّق يدوياً وفق مصادر رسمية قبل النشر.';
	@override String get project_purpose_title => 'ما هو Thaqafa؟';
	@override String get project_purpose_body => 'حدث تاريخي موثَّق من التاريخ الإسلامي في كل يوم، بالتقويمَين الهجري والميلادي. كلّ مدخل — حدث، درس، يوم مبارك — يُحقَّق يدوياً من مصادر كلاسيكية رسمية (الطبري، ابن كثير، الكتب الستة) قبل النشر. نحذف مدخلاً مشكوكاً فيه بدلاً من إبقاء خاطئ. الوعد غير مشروط: كل مدخل مرَّ بمراجعة تحريرية.';
	@override String get education_title => 'التعليم';
	@override String get education_epitech => 'Epitech Paris — ماجستير في هندسة البرمجيات';
	@override String get education_sfsu => 'San Francisco State University — شهادة';
	@override String get experience_title => 'الخبرة';
	@override String get experience_madura_title => 'Madura Capital Management — مطوّر Python / DevOps';
	@override String get experience_madura_period => 'سبتمبر ٢٠٢٤ — حتى الآن';
	@override String get experience_madura_desc => 'أدوات داخلية لصندوق تحوّط — feeders للبيانات، أنابيب ETL بـPrefect، واجهة تداول بـReact/TypeScript.';
	@override String get experience_snap_title => 'Snapchat (SnapLab) — مطوّر Python / DevOps / AWS';
	@override String get experience_snap_period => 'مايو ٢٠٢٢ — سبتمبر ٢٠٢٤';
	@override String get experience_snap_desc => 'لوحة تسجيل جلسات لفريق Connected Spectacles. خلفية FastAPI على AWS ECS عبر Terraform؛ واجهة React.';
	@override String get experience_enedis_title => 'Enedis (EDF) — مطوّر Python / DevOps / سحابة';
	@override String get experience_enedis_period => 'أبريل ٢٠٢١ — أبريل ٢٠٢٢';
	@override String get experience_enedis_desc => 'منصّة لمتابعة طلبات العملاء مع دردشة. FastAPI على AWS Lambda (Serverless)؛ واجهة React/TypeScript.';
	@override String get experience_bnp_title => 'BNP Paribas Personal Finance — مطوّر Python / DevOps';
	@override String get experience_bnp_period => 'سبتمبر ٢٠١٩ — مارس ٢٠٢١';
	@override String get experience_bnp_desc => 'نقل بنية أحادية إلى خدمات صغيرة. واجهات Python تتيح لعلماء البيانات الوصول إلى مجموعات بيانات كبيرة عبر جلسات IDE آمنة.';
	@override String get experience_cloudeasier_title => 'Cloudeasier (Accenture) — مطوّر Python / سحابة';
	@override String get experience_cloudeasier_period => 'فبراير ٢٠١٩ — أغسطس ٢٠١٩';
	@override String get experience_cloudeasier_desc => 'Python على AWS Lambda وGCP Cloud Functions لتسعير الحوسبة وجدولتها. نشر بـTerraform.';
	@override String get skills_title => 'المهارات';
	@override String get other_projects_title => 'مشاريع أخرى';
	@override String get other_projects_majlisna_title => 'Majlisna';
	@override String get other_projects_majlisna_desc => 'منصّة ألعاب جماعية بالوقت الحقيقي، بنسخ مُؤسلَمة من Undercover وCodenames.';
	@override String get other_projects_majlisna_link => 'majlisna.app';
	@override String get other_projects_latabdhir_title => 'LaTabdhir';
	@override String get other_projects_latabdhir_desc => 'عدّاد ذكر مبنيّ حول التذكيرات اليومية والاستمرارية.';
	@override String get other_projects_latabdhir_link => 'latabdhir.ae';
	@override String get mentoring_title => 'إرشاد مجاني';
	@override String get mentoring_body => 'بخبرتي أستطيع مساعدة مهندسي علوم الحاسوب والمطورين أو أي شخص يريد تعلم المزيد عن علوم الحاسوب — مجاناً. يمكنني أيضاً المساعدة في كتابة أو تحسين السيرة الذاتية، فهم سوق العمل، التحضير للمقابلات، أو تقديم نصائح عامة للبحث عن وظيفة. تواصل معي عبر البريد الإلكتروني أو الهاتف. إذا لم أرد، اترك رسالة وسأتصل بك.';
	@override String get charity_title => 'ادعم الأمّة';
	@override String get charity_subtitle => 'إن كان هذا المشروع نافعاً لك، فكّر بتبرّع لإحدى هذه الجمعيات.';
	@override String get charity_human_appeal_desc => 'جمعية إنسانية دولية تعمل في مناطق النزاعات والأمن الغذائي وكفالة الأيتام.';
	@override String get charity_ummah_charity_desc => 'جمعية فرنسية عريقة تعمل في التعليم والوصول إلى الماء والإغاثة الطارئة.';
	@override String get charity_donate => 'تبرّع';
	@override String get contact_title => 'تواصل معي';
	@override String get contact_email => 'البريد';
	@override String get contact_phone => 'الهاتف';
	@override String get contact_linkedin => 'LinkedIn';
	@override String get contact_github => 'GitHub';
	@override String get quran_attribution_title => 'إصدارات القرآن المعتمدة';
	@override String get quran_attribution_body => 'النص العربي من المصحف العثماني لمشروع Tanzil. الترجمة الإنجليزية لـ Saheeh International. الترجمة الفرنسية لمحمد حميد الله. تُختار الآية المعروضة قبل التذييل من استشهادات حدث اليوم إن وُجدت؛ وإلا تُعرض سورة يوسف ١٢:١١١ — «لقد كان في قصصهم عبرة لأولي الألباب» — كنصّ افتتاحي ثابت.';
	@override String get created_by => 'من تأليف';
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
	@override String get delete_account_cta => 'حذف الحساب';
	@override String get delete_account_title => 'حذف الحساب؟';
	@override String get delete_account_warning => 'هذا الإجراء يحذف حسابك وجميع المحفوظات بشكل دائم ولا يمكن التراجع عنه.';
	@override String get delete_account_cancel => 'إلغاء';
	@override String get delete_account_confirm => 'احذف نهائيًا';
}

// Path: legal
class _TranslationsLegalAr implements TranslationsLegalEn {
	_TranslationsLegalAr._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'قانوني';
	@override String get privacy => 'سياسة الخصوصية';
	@override String get terms => 'شروط الخدمة';
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
			'onboarding.skip' => 'تخطّى',
			'onboarding.kContinue' => 'تابِع',
			'onboarding.lang_eyebrow' => 'اختر لغتك',
			'onboarding.lang_headline' => 'اقرأ بلغتك.',
			'onboarding.lang_subhead' => 'القراءة ومصادرها مترجمة إلى العربية والإنجليزية والفرنسية. يمكنك التغيير لاحقًا من الإعدادات.',
			'onboarding.lang_en' => 'English',
			'onboarding.lang_fr' => 'Français',
			'onboarding.lang_ar' => 'العربية',
			'onboarding.notif_eyebrow' => 'موعد يومي',
			'onboarding.notif_headline' => 'تذكير هادئ،\nمرّة في اليوم.',
			'onboarding.notif_subhead' => 'اختر الساعة التي تناسبك. لا إشعارات أخرى، ويمكنك إيقاف هذا في أيّ وقت.',
			'onboarding.notif_enable' => 'إشعار يومي',
			'onboarding.notif_time' => 'وقت التذكير',
			'today.title' => 'اليوم',
			'today.loading' => 'جارٍ التحميل',
			'today.load_failed' => 'تعذّر تحميل اليوم.',
			'today.more_reading' => 'قراءات إضافية لهذا اليوم',
			'today.introduction' => 'مقدّمة',
			'today.the_reading' => 'القراءة',
			'today.end_of_reading' => 'نهاية قراءة اليوم',
			'today.verify' => 'تحقّق',
			'verification.scholar_reviewed' => 'مراجَع علمياً',
			'verification.cross_verified' => 'مصادر متعدّدة',
			'verification.single_source' => 'مصدر واحد',
			'verification.unverified' => 'غير محقّق',
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
			'settings.notification_test' => 'إرسال إشعار تجريبي',
			'settings.notification_test_title' => 'ثقافة — اختبار',
			'settings.notification_test_body' => 'إذا قرأتَ هذا فالإشعارات تعمل.',
			'settings.notification_test_pending' => 'سيصل إشعار تجريبي بعد خمس ثوانٍ تقريبًا.',
			'settings.notification_permission_warning' => 'الإشعارات مُفعَّلة داخل التطبيق لكن نظام iOS يحجبها. افتح إعدادات النظام للسماح بها.',
			'settings.notification_open_system_settings' => 'فتح إعدادات النظام',
			'settings.observances_link' => 'تصفّح الأيام المُباركة',
			'settings.about' => 'حول',
			'errors.generic' => 'حدث خطأ ما.',
			'errors.offline' => 'يبدو أنّك غير متّصل.',
			'errors.not_found' => 'غير موجود.',
			'bookmarks.title' => 'المحفوظات',
			'bookmarks.empty' => 'لم يُحفَظ شيء بعد. اضغط «حفظ» على مدخل لإبقائه.',
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
			'about.nav_label' => 'حولنا',
			'about.title' => 'حول المشروع · عنّي',
			'about.subtitle' => 'كلمات قليلة عن هذا الموقع، ومَن بناه، وكيف يمكن التواصل.',
			'about.name' => 'صهيب الطرابلسي',
			'about.role' => 'مهندس برمجيات',
			'about.bio' => 'مهندس برمجيات بسبع سنوات من الخبرة، أغلبها في Python وReact. أطلقتُ "Thaqafa" لأنّي أردتُ عادة قراءة يومية مرتكزة على التاريخ الإسلامي الكلاسيكي. كلّ مدخل مدقَّق يدوياً وفق مصادر رسمية قبل النشر.',
			'about.project_purpose_title' => 'ما هو Thaqafa؟',
			'about.project_purpose_body' => 'حدث تاريخي موثَّق من التاريخ الإسلامي في كل يوم، بالتقويمَين الهجري والميلادي. كلّ مدخل — حدث، درس، يوم مبارك — يُحقَّق يدوياً من مصادر كلاسيكية رسمية (الطبري، ابن كثير، الكتب الستة) قبل النشر. نحذف مدخلاً مشكوكاً فيه بدلاً من إبقاء خاطئ. الوعد غير مشروط: كل مدخل مرَّ بمراجعة تحريرية.',
			'about.education_title' => 'التعليم',
			'about.education_epitech' => 'Epitech Paris — ماجستير في هندسة البرمجيات',
			'about.education_sfsu' => 'San Francisco State University — شهادة',
			'about.experience_title' => 'الخبرة',
			'about.experience_madura_title' => 'Madura Capital Management — مطوّر Python / DevOps',
			'about.experience_madura_period' => 'سبتمبر ٢٠٢٤ — حتى الآن',
			'about.experience_madura_desc' => 'أدوات داخلية لصندوق تحوّط — feeders للبيانات، أنابيب ETL بـPrefect، واجهة تداول بـReact/TypeScript.',
			'about.experience_snap_title' => 'Snapchat (SnapLab) — مطوّر Python / DevOps / AWS',
			'about.experience_snap_period' => 'مايو ٢٠٢٢ — سبتمبر ٢٠٢٤',
			'about.experience_snap_desc' => 'لوحة تسجيل جلسات لفريق Connected Spectacles. خلفية FastAPI على AWS ECS عبر Terraform؛ واجهة React.',
			'about.experience_enedis_title' => 'Enedis (EDF) — مطوّر Python / DevOps / سحابة',
			'about.experience_enedis_period' => 'أبريل ٢٠٢١ — أبريل ٢٠٢٢',
			'about.experience_enedis_desc' => 'منصّة لمتابعة طلبات العملاء مع دردشة. FastAPI على AWS Lambda (Serverless)؛ واجهة React/TypeScript.',
			'about.experience_bnp_title' => 'BNP Paribas Personal Finance — مطوّر Python / DevOps',
			'about.experience_bnp_period' => 'سبتمبر ٢٠١٩ — مارس ٢٠٢١',
			'about.experience_bnp_desc' => 'نقل بنية أحادية إلى خدمات صغيرة. واجهات Python تتيح لعلماء البيانات الوصول إلى مجموعات بيانات كبيرة عبر جلسات IDE آمنة.',
			'about.experience_cloudeasier_title' => 'Cloudeasier (Accenture) — مطوّر Python / سحابة',
			'about.experience_cloudeasier_period' => 'فبراير ٢٠١٩ — أغسطس ٢٠١٩',
			'about.experience_cloudeasier_desc' => 'Python على AWS Lambda وGCP Cloud Functions لتسعير الحوسبة وجدولتها. نشر بـTerraform.',
			'about.skills_title' => 'المهارات',
			'about.other_projects_title' => 'مشاريع أخرى',
			'about.other_projects_majlisna_title' => 'Majlisna',
			'about.other_projects_majlisna_desc' => 'منصّة ألعاب جماعية بالوقت الحقيقي، بنسخ مُؤسلَمة من Undercover وCodenames.',
			'about.other_projects_majlisna_link' => 'majlisna.app',
			'about.other_projects_latabdhir_title' => 'LaTabdhir',
			'about.other_projects_latabdhir_desc' => 'عدّاد ذكر مبنيّ حول التذكيرات اليومية والاستمرارية.',
			'about.other_projects_latabdhir_link' => 'latabdhir.ae',
			'about.mentoring_title' => 'إرشاد مجاني',
			'about.mentoring_body' => 'بخبرتي أستطيع مساعدة مهندسي علوم الحاسوب والمطورين أو أي شخص يريد تعلم المزيد عن علوم الحاسوب — مجاناً. يمكنني أيضاً المساعدة في كتابة أو تحسين السيرة الذاتية، فهم سوق العمل، التحضير للمقابلات، أو تقديم نصائح عامة للبحث عن وظيفة. تواصل معي عبر البريد الإلكتروني أو الهاتف. إذا لم أرد، اترك رسالة وسأتصل بك.',
			'about.charity_title' => 'ادعم الأمّة',
			'about.charity_subtitle' => 'إن كان هذا المشروع نافعاً لك، فكّر بتبرّع لإحدى هذه الجمعيات.',
			'about.charity_human_appeal_desc' => 'جمعية إنسانية دولية تعمل في مناطق النزاعات والأمن الغذائي وكفالة الأيتام.',
			'about.charity_ummah_charity_desc' => 'جمعية فرنسية عريقة تعمل في التعليم والوصول إلى الماء والإغاثة الطارئة.',
			'about.charity_donate' => 'تبرّع',
			'about.contact_title' => 'تواصل معي',
			'about.contact_email' => 'البريد',
			'about.contact_phone' => 'الهاتف',
			'about.contact_linkedin' => 'LinkedIn',
			'about.contact_github' => 'GitHub',
			'about.quran_attribution_title' => 'إصدارات القرآن المعتمدة',
			'about.quran_attribution_body' => 'النص العربي من المصحف العثماني لمشروع Tanzil. الترجمة الإنجليزية لـ Saheeh International. الترجمة الفرنسية لمحمد حميد الله. تُختار الآية المعروضة قبل التذييل من استشهادات حدث اليوم إن وُجدت؛ وإلا تُعرض سورة يوسف ١٢:١١١ — «لقد كان في قصصهم عبرة لأولي الألباب» — كنصّ افتتاحي ثابت.',
			'about.created_by' => 'من تأليف',
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
			'auth.delete_account_cta' => 'حذف الحساب',
			'auth.delete_account_title' => 'حذف الحساب؟',
			'auth.delete_account_warning' => 'هذا الإجراء يحذف حسابك وجميع المحفوظات بشكل دائم ولا يمكن التراجع عنه.',
			'auth.delete_account_cancel' => 'إلغاء',
			'auth.delete_account_confirm' => 'احذف نهائيًا',
			'legal.title' => 'قانوني',
			'legal.privacy' => 'سياسة الخصوصية',
			'legal.terms' => 'شروط الخدمة',
			_ => null,
		};
	}
}

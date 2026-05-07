import 'package:home_widget/home_widget.dart';
import 'package:thaqafa/api/generated/models/today_calendar.dart';
import 'package:thaqafa/api/generated/models/today_response_headline_sealed.dart';
import 'package:thaqafa/api/generated/models/today_response.dart';

/// Pushes Today payload into the platform shared container so the
/// native widgets (iOS WidgetKit / Android Glance) can read it.
///
/// Keys used by the widget extensions (must stay in sync with
/// ``ios/ThaqafaWidget/ThaqafaWidgetEntry.swift`` and the Android side):
///
///   - ``hijri_day``   ``int``    e.g. 19
///   - ``hijri_month`` ``String`` e.g. "Dhū al-Qaʿda"
///   - ``hijri_year``  ``int``    e.g. 1447
///   - ``greg_iso``    ``String`` e.g. "2026-05-06"
///   - ``era``         ``String`` event era / lesson category
///   - ``title``       ``String`` localised headline title (EN today)
///   - ``slug``        ``String`` deep-link target
///
/// Phase 4 only writes; the native widgets render. Wiring the
/// timeline reload from the iOS side requires the Widget Extension
/// target to exist (see `mobile/native_widgets/README.md`).
class HomeWidgetWriter {
  HomeWidgetWriter._();

  static const String _kAndroidName = 'ThaqafaWidgetProvider';
  static const String _kIosName = 'ThaqafaWidget';

  /// Configure the App Group used by both Flutter and the WidgetKit
  /// extension on iOS. The same string must be set in both
  /// entitlements files. Replace with your prod App Group ID before
  /// signing for the App Store.
  static const String _kAppGroupId = 'group.app.thaqafa.app';

  static Future<void> ensureConfigured() async {
    await HomeWidget.setAppGroupId(_kAppGroupId);
  }

  /// Push the Today payload + trigger a refresh on the native widgets.
  /// Locale is the FE-side current locale code so the widget shows
  /// the same language the app does.
  static Future<void> publishToday(TodayResponse data, String locale) async {
    await ensureConfigured();
    final cal = data.today;
    final headline = data.headline;

    await _writeCalendar(cal);
    if (headline != null) {
      await _writeHeadline(headline, locale);
    }

    await HomeWidget.updateWidget(
      androidName: _kAndroidName,
      iOSName: _kIosName,
    );
  }

  static Future<void> _writeCalendar(TodayCalendar cal) async {
    await HomeWidget.saveWidgetData('hijri_day', cal.hijri.day);
    await HomeWidget.saveWidgetData('hijri_month', cal.hijri.month);
    await HomeWidget.saveWidgetData('hijri_month_short', cal.hijri.monthShort);
    await HomeWidget.saveWidgetData('hijri_year', cal.hijri.year);
    await HomeWidget.saveWidgetData(
      'greg_iso',
      '${cal.gregorian.year}-${cal.gregorian.month}-${cal.gregorian.day.toString().padLeft(2, '0')}',
    );
    await HomeWidget.saveWidgetData('greg_weekday', cal.gregorian.weekday);
  }

  static Future<void> _writeHeadline(
    TodayResponseHeadlineSealed headline,
    String locale,
  ) async {
    if (headline is TodayResponseHeadlineSealedEventDetail) {
      await HomeWidget.saveWidgetData(
        'title',
        _pick(locale, headline.title, headline.titleAr, headline.titleFr),
      );
      await HomeWidget.saveWidgetData('era', headline.era ?? '');
      await HomeWidget.saveWidgetData('slug', headline.id);
      await HomeWidget.saveWidgetData('kind', 'event');
    } else if (headline is TodayResponseHeadlineSealedLessonDetail) {
      await HomeWidget.saveWidgetData(
        'title',
        _pick(locale, headline.title, headline.titleAr, headline.titleFr),
      );
      await HomeWidget.saveWidgetData('era', headline.category);
      await HomeWidget.saveWidgetData('slug', headline.id);
      await HomeWidget.saveWidgetData('kind', 'lesson');
    }
  }

  static String _pick(String lang, String en, String? ar, String? fr) =>
      switch (lang) {
        'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
        'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
        _ => en,
      };
}

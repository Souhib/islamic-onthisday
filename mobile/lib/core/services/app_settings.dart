import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/core/analytics/analytics.dart';
import 'package:thaqafa/core/di/providers.dart';
import 'package:thaqafa/i18n/strings.g.dart';

/// Reactive theme-mode preference. Persisted via `PreferencesService`.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final raw = ref.read(prefsServiceProvider).themeMode;
    return _decode(raw);
  }

  Future<void> set(ThemeMode mode) async {
    await ref.read(prefsServiceProvider).setThemeMode(_encode(mode));
    state = mode;
  }

  static ThemeMode _decode(String raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Reactive locale preference. Persists EN / FR / AR; null lets the
/// device locale win.
class LocaleNotifier extends Notifier<AppLocale?> {
  @override
  AppLocale? build() {
    final raw = ref.read(prefsServiceProvider).locale;
    return _decode(raw);
  }

  Future<void> set(AppLocale? loc) async {
    final prefs = ref.read(prefsServiceProvider);
    if (loc == null) {
      await prefs.setLocale('');
      LocaleSettings.useDeviceLocale();
    } else {
      await prefs.setLocale(loc.languageCode);
      LocaleSettings.setLocale(loc);
    }
    state = loc;
    Analytics.instance.trackLanguageChange(LocaleSettings.currentLocale.languageCode);
  }

  static AppLocale? _decode(String? raw) => switch (raw) {
        'en' => AppLocale.en,
        'fr' => AppLocale.fr,
        'ar' => AppLocale.ar,
        _ => null,
      };
}

final localeProvider =
    NotifierProvider<LocaleNotifier, AppLocale?>(LocaleNotifier.new);

/// User-controlled reading-size multiplier. Plugged into a top-level
/// ``MediaQuery`` so every ``Text`` in the tree scales without any
/// per-widget plumbing. Pinch-to-zoom on a long scrollable list breaks
/// vertical scroll (gesture-arena conflict) — the segmented preset row
/// in Settings is the standard pattern Apple Books / NYT / Medium use
/// for the same reason.
class ReadingScaleNotifier extends Notifier<double> {
  @override
  double build() => ref.read(prefsServiceProvider).readingScale;

  Future<void> set(double value) async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setReadingScale(value);
    state = value;
  }
}

final readingScaleProvider =
    NotifierProvider<ReadingScaleNotifier, double>(ReadingScaleNotifier.new);

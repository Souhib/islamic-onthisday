import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper around `SharedPreferences`. Holds the keys we
/// touch from the app and exposes typed read/write helpers — keeps
/// stringly-typed access out of the rest of the codebase.
class PreferencesService {
  PreferencesService(this._prefs);

  static const _kHasCompletedOnboarding = 'has_completed_onboarding';
  static const _kThemeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _kLocale = 'locale'; // 'en' | 'fr' | 'ar'
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kNotificationHour = 'notification_hour'; // 0-23
  static const _kNotificationMinute = 'notification_minute'; // 0-59

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_kHasCompletedOnboarding) ?? false;
  Future<void> setHasCompletedOnboarding(bool value) =>
      _prefs.setBool(_kHasCompletedOnboarding, value);

  String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_kThemeMode, mode);

  String? get locale => _prefs.getString(_kLocale);
  Future<void> setLocale(String code) => _prefs.setString(_kLocale, code);

  // Default OFF: the App Store / Play guidelines and basic UX courtesy
  // both call for explicit opt-in to a privacy-sensitive feature.
  // Existing installs that already saved a preference keep it; only
  // fresh installs land on this default.
  bool get notificationsEnabled =>
      _prefs.getBool(_kNotificationsEnabled) ?? false;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_kNotificationsEnabled, value);

  int get notificationHour => _prefs.getInt(_kNotificationHour) ?? 8;
  Future<void> setNotificationHour(int hour) =>
      _prefs.setInt(_kNotificationHour, hour);

  int get notificationMinute => _prefs.getInt(_kNotificationMinute) ?? 0;
  Future<void> setNotificationMinute(int minute) =>
      _prefs.setInt(_kNotificationMinute, minute);
}

/// API endpoint config. The dev/prod target is currently a single
/// production deployment — the simulator hits it directly. When a
/// staging origin lands or the user wants to point at a local
/// backend, switch via `--dart-define=THAQAFA_API_BASE=http://...`.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'THAQAFA_API_BASE',
    defaultValue: 'https://news.majlisna.app',
  );

  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 12);
}

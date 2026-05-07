import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry config. Mirrors the backend / web pattern: gated entirely on
/// the presence of a DSN at compile time. Empty DSN = no init, no
/// network — zero overhead in dev or unauthored builds.
///
/// Pass at build time via:
///   flutter run --dart-define=SENTRY_DSN=https://...@sentry.io/...
///
/// Sample rates default to 1.0 in debug and 0.2 in release so we keep
/// signal high during development without blowing the prod quota.
class SentryConfig {
  SentryConfig._();

  static const String dsn = String.fromEnvironment('SENTRY_DSN');
  static const String release = String.fromEnvironment(
    'SENTRY_RELEASE',
    defaultValue: 'iotd_mobile@1.0.0+1',
  );
  static const String environment = String.fromEnvironment(
    'SENTRY_ENV',
    defaultValue: kReleaseMode ? 'production' : 'development',
  );
}

/// Boot Sentry if a DSN is provided. Wrap ``runApp`` with the result so
/// uncaught Flutter / async errors flow to Sentry. When no DSN is set,
/// fall back to running ``appRunner`` directly.
Future<void> bootSentry(Future<void> Function() appRunner) async {
  if (SentryConfig.dsn.isEmpty) {
    await appRunner();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;
      options.release = SentryConfig.release;
      options.environment = SentryConfig.environment;
      options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
      options.attachScreenshot = false;
      options.attachViewHierarchy = false;
      options.sendDefaultPii = false;
    },
    appRunner: appRunner,
  );
}

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// GlitchTip / Sentry config. Self-hosted GlitchTip speaks the Sentry
/// wire format, so the official ``sentry_flutter`` SDK works with the
/// project's GlitchTip DSN as-is. Gated entirely on the presence of a
/// DSN at compile time — empty DSN = no init, no network — zero
/// overhead in dev or unauthored builds.
///
/// Pass at build time via:
///   flutter run --dart-define=SENTRY_DSN=https://...@glitchtip.majlisna.app/N
///
/// Sample rates default to 1.0 in debug and 0.2 in release so we keep
/// signal high during development without blowing the GlitchTip quota.
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

/// Boot Sentry if a DSN is provided. Wraps ``runApp`` so uncaught Flutter
/// + async errors flow to GlitchTip. When no DSN is set, fall back to
/// running ``appRunner`` directly with no instrumentation.
///
/// In addition to ``SentryFlutter.init``'s built-in error capture, we
/// explicitly wire ``FlutterError.onError`` and
/// ``PlatformDispatcher.instance.onError`` so that:
///   - render-phase errors from widget builds reach the SDK,
///   - async errors thrown from event handlers / futures still reach
///     the SDK after returning to the framework,
///   - the original handlers are preserved so debug-mode red screens
///     and stdout traces stay intact.
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
      options.beforeSend = (event, hint) async {
        // Strip auth-bearing headers if a request breadcrumb leaked
        // through. The dio interceptor stack should never put them in
        // a breadcrumb in the first place — defense in depth.
        final request = event.request;
        if (request != null && request.headers.isNotEmpty) {
          for (final key in request.headers.keys.toList()) {
            final lk = key.toLowerCase();
            if (lk == 'authorization' || lk == 'cookie' || lk == 'x-api-key') {
              request.headers[key] = '[redacted]';
            }
          }
        }
        return event;
      };
    },
    appRunner: appRunner,
  );

  // Render-phase errors. Forward to Sentry first (so the issue is logged)
  // then to the previously-registered handler so debug-mode red boxes /
  // log lines still happen.
  final priorFlutterErrorHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) async {
    await Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );
    if (priorFlutterErrorHandler != null) priorFlutterErrorHandler(details);
  };

  // Async / engine-level errors. Returning ``true`` tells the framework
  // we've handled the error so the default handler doesn't also crash
  // the app on top of our capture.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/app.dart';
import 'package:thaqafa/core/di/providers.dart';
import 'package:thaqafa/core/notifications/notification_service.dart';
import 'package:thaqafa/core/observability/sentry_config.dart';
import 'package:thaqafa/core/storage/preferences_service.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

/// Boot the app:
///   - Ensure Flutter binding
///   - Initialise Slang (i18n)
///   - Construct the prefs service (one-shot async)
///   - Wire `prefsServiceProvider` override into the ProviderScope
///   - Run with `TranslationProvider` so `Translations.of(context)` works
///
/// Sentry wraps ``runApp`` when a DSN is provided at build time
/// (``--dart-define=SENTRY_DSN=...``). With no DSN the SDK isn't
/// initialised, so dev builds incur zero overhead.
Future<void> bootstrap() async {
  // Marionette MCP — debug-only widget-tree introspection + interaction
  // surface for AI agents. Replaces the default WidgetsFlutterBinding;
  // in release builds we fall back to the standard binding.
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  LocaleSettings.useDeviceLocale();
  final prefs = await PreferencesService.create();
  await NotificationService.instance.ensureInitialised();

  await bootSentry(() async {
    runApp(
      ProviderScope(
        overrides: [prefsServiceProvider.overrideWithValue(prefs)],
        child: TranslationProvider(child: const ThaqafaApp()),
      ),
    );
  });
}

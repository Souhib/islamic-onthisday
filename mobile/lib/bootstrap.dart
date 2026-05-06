import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/app.dart';
import 'package:iotd_mobile/core/di/providers.dart';
import 'package:iotd_mobile/core/storage/preferences_service.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

/// Boot the app:
///   - Ensure Flutter binding
///   - Initialise Slang (i18n)
///   - Construct the prefs service (one-shot async)
///   - Wire `prefsServiceProvider` override into the ProviderScope
///   - Run with `TranslationProvider` so `Translations.of(context)` works
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

  runApp(
    ProviderScope(
      overrides: [prefsServiceProvider.overrideWithValue(prefs)],
      child: TranslationProvider(child: const IotdApp()),
    ),
  );
}

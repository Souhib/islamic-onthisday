import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/router/app_router.dart';
import 'package:iotd_mobile/core/services/app_settings.dart';
import 'package:iotd_mobile/core/theme/app_theme.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';

/// Root MaterialApp.router — wires GoRouter, Slang locale delegates,
/// and the light/dark theme builders.
class IotdApp extends ConsumerWidget {
  const IotdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => Translations.of(ctx).app.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}

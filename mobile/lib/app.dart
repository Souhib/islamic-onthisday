import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/services/app_settings.dart';
import 'package:thaqafa/core/theme/app_theme.dart';
import 'package:thaqafa/i18n/strings.g.dart';

/// Root MaterialApp.router — wires GoRouter, Slang locale delegates,
/// and the light/dark theme builders.
class ThaqafaApp extends ConsumerWidget {
  const ThaqafaApp({super.key});

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

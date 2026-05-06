import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';

/// Material theme builder. The bulk of color decisions go through
/// `IotdTokens` (a `ThemeExtension`); this just wires Material's slots
/// (scaffold, app bar, etc.) to the same palette so a stock Material
/// widget reads correctly without us reaching into tokens manually.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final tokens = IotdTokens.light();
    return _build(tokens, Brightness.light);
  }

  static ThemeData dark() {
    final tokens = IotdTokens.dark();
    return _build(tokens, Brightness.dark);
  }

  static ThemeData _build(IotdTokens t, Brightness brightness) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: t.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.accent,
        brightness: brightness,
        surface: t.paper,
        onSurface: t.ink,
        primary: t.accent,
        onPrimary: t.paper,
        error: t.warn,
      ),
      textTheme: GoogleFonts.cormorantGaramondTextTheme().apply(
        bodyColor: t.inkSoft,
        displayColor: t.ink,
      ),
      dividerColor: t.rule,
      dividerTheme: DividerThemeData(color: t.rule, thickness: 0.5, space: 0),
      appBarTheme: AppBarTheme(
        backgroundColor: t.paper,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      iconTheme: IconThemeData(color: t.ink, size: 22),
    );
    return base.copyWith(extensions: [t]);
  }
}

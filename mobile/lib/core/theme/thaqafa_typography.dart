import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography ramp — the four font families used across the app:
///   - Cormorant Garamond (serif) — headlines, dates, body copy
///   - Inter Tight (sans) — UI fallback (rare; serif dominates)
///   - JetBrains Mono — eyebrows, chips, refs, all-caps labels
///   - Amiri — Arabic content (RTL, naskh)
///
/// Loaded via `google_fonts` so the binaries don't have to live in the
/// repo. Cached locally after first launch.
class ThaqafaTypography {
  ThaqafaTypography._();

  static TextStyle serif({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.normal,
    double height = 1.15,
    double letterSpacing = 0,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: size,
    color: color,
    fontWeight: weight,
    fontStyle: style,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle sans({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.4,
  }) => GoogleFonts.interTight(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
  );

  static TextStyle mono({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 1.4,
    bool uppercase = true,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: 1.0,
  );

  static TextStyle arabic({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.9,
  }) => GoogleFonts.amiri(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
  );
}

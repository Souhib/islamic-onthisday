import 'package:flutter/material.dart';

/// Editorial design tokens — port of the web's CSS variables and the
/// design mockup's `IOTD_TOKENS`.
///
/// Light mode = warm cream paper. Dark mode = deep ink-blue. Accent is
/// verdigris/oxidized-copper green; warn is warm umber for unverified
/// items. Anything color-related in the app should reach for these
/// tokens via `Theme.of(context).extension<IotdTokens>()` rather than
/// hard-coding hex values — same posture as `Colors.css` in the web bundle.
@immutable
class IotdTokens extends ThemeExtension<IotdTokens> {
  const IotdTokens({
    required this.paper,
    required this.paperHi,
    required this.paperLo,
    required this.ink,
    required this.inkSoft,
    required this.inkMute,
    required this.inkFaint,
    required this.rule,
    required this.ruleSoft,
    required this.accent,
    required this.accentBg,
    required this.warn,
    required this.warnBg,
  });

  /// Light tokens — cream paper.
  factory IotdTokens.light() => const IotdTokens(
    paper: Color(0xFFF5F0E6),
    paperHi: Color(0xFFFBF7EE),
    paperLo: Color(0xFFEDE6D8),
    ink: Color(0xFF1B1A17),
    inkSoft: Color(0xFF3A372F),
    inkMute: Color(0xFF6E6A5C),
    inkFaint: Color(0xFFA39E8E),
    rule: Color(0xFFD5CDB8),
    ruleSoft: Color(0xFFE5DDC9),
    // The mockup uses oklch() — Flutter takes sRGB, so we precompute
    // the closest hex. Verdigris green at oklch(58% 0.06 165).
    accent: Color(0xFF3A8A6B),
    accentBg: Color(0xFFE5EFE9),
    // Warm umber at oklch(58% 0.08 60).
    warn: Color(0xFFA86E32),
    warnBg: Color(0xFFF1E7D6),
  );

  /// Dark tokens — deep ink-blue.
  factory IotdTokens.dark() => const IotdTokens(
    paper: Color(0xFF0F1217),
    paperHi: Color(0xFF161A21),
    paperLo: Color(0xFF0A0D12),
    ink: Color(0xFFEDE6D2),
    inkSoft: Color(0xFFC9C2AD),
    inkMute: Color(0xFF8E8876),
    inkFaint: Color(0xFF5A5547),
    rule: Color(0xFF272B33),
    ruleSoft: Color(0xFF1B1F26),
    accent: Color(0xFF6FB394),
    accentBg: Color(0xFF1F2D27),
    warn: Color(0xFFC9985E),
    warnBg: Color(0xFF2C241A),
  );

  final Color paper;
  final Color paperHi;
  final Color paperLo;
  final Color ink;
  final Color inkSoft;
  final Color inkMute;
  final Color inkFaint;
  final Color rule;
  final Color ruleSoft;
  final Color accent;
  final Color accentBg;
  final Color warn;
  final Color warnBg;

  @override
  ThemeExtension<IotdTokens> copyWith({
    Color? paper,
    Color? paperHi,
    Color? paperLo,
    Color? ink,
    Color? inkSoft,
    Color? inkMute,
    Color? inkFaint,
    Color? rule,
    Color? ruleSoft,
    Color? accent,
    Color? accentBg,
    Color? warn,
    Color? warnBg,
  }) => IotdTokens(
    paper: paper ?? this.paper,
    paperHi: paperHi ?? this.paperHi,
    paperLo: paperLo ?? this.paperLo,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    inkMute: inkMute ?? this.inkMute,
    inkFaint: inkFaint ?? this.inkFaint,
    rule: rule ?? this.rule,
    ruleSoft: ruleSoft ?? this.ruleSoft,
    accent: accent ?? this.accent,
    accentBg: accentBg ?? this.accentBg,
    warn: warn ?? this.warn,
    warnBg: warnBg ?? this.warnBg,
  );

  @override
  ThemeExtension<IotdTokens> lerp(ThemeExtension<IotdTokens>? other, double t) {
    if (other is! IotdTokens) return this;
    return IotdTokens(
      paper: Color.lerp(paper, other.paper, t)!,
      paperHi: Color.lerp(paperHi, other.paperHi, t)!,
      paperLo: Color.lerp(paperLo, other.paperLo, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkMute: Color.lerp(inkMute, other.inkMute, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      ruleSoft: Color.lerp(ruleSoft, other.ruleSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnBg: Color.lerp(warnBg, other.warnBg, t)!,
    );
  }
}

/// Convenience accessor — `context.tokens.accent` reads cleaner than
/// `Theme.of(context).extension<IotdTokens>()!.accent`.
extension IotdTokensAccess on BuildContext {
  IotdTokens get tokens => Theme.of(this).extension<IotdTokens>()!;
}

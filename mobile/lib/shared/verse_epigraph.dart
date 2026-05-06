import 'package:flutter/material.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// A centered Qur'anic citation rendered as a section divider — vocalised
/// Arabic on top, locale translation in serif italic, sūra + ayah in
/// mono caps below, framed by two rosette frieze rules.
///
/// In V1 we ship the editorial fallback **Yūsuf 12:111**
/// (*"there is a lesson for those of understanding"*) inlined as a const.
/// Phase 1 will wire the same component to ``quran-extracts.json`` so
/// the verse can change per event.
class VerseEpigraph extends StatelessWidget {
  const VerseEpigraph({
    required this.ar,
    required this.translation,
    required this.surahName,
    required this.reference,
    super.key,
  });

  /// The standing fallback (Yūsuf 12:111). The fixed editorial epigraph
  /// for the project — same role as the web's footer-area frame.
  factory VerseEpigraph.fallback(BuildContext context) {
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    return VerseEpigraph(
      ar: _kFallbackAr,
      translation: switch (lang) {
        'ar' => '',
        'fr' => _kFallbackFr,
        _ => _kFallbackEn,
      },
      surahName: lang == 'ar' ? 'يوسف' : 'Yūsuf',
      reference: '12:111',
    );
  }

  final String ar;
  final String translation;
  final String surahName;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final prefix = lang == 'ar' ? 'سورة' : 'Sūrat';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        children: [
          const FriezeRule(rosetteOnly: true, marginTop: 0, marginBottom: 24),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ar,
              textAlign: TextAlign.center,
              style: IotdTypography.arabic(
                size: 22,
                color: t.ink,
                height: 1.9,
              ),
            ),
          ),
          if (translation.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              '“$translation”',
              textAlign: TextAlign.center,
              style: IotdTypography.serif(
                size: 16,
                color: t.inkSoft,
                style: FontStyle.italic,
                height: 1.55,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            '${prefix.toUpperCase()} ${surahName.toUpperCase()} · $reference',
            style: IotdTypography.mono(
              size: 11,
              color: t.inkMute,
              letterSpacing: 2,
            ),
          ),
          const FriezeRule(rosetteOnly: true, marginTop: 24, marginBottom: 0),
        ],
      ),
    );
  }
}

const String _kFallbackAr =
    'لَقَدْ كَانَ فِى قَصَصِهِمْ عِبْرَةٌۭ لِّأُو۟لِى ٱلْأَلْبَٰبِ ۗ مَا كَانَ '
    'حَدِيثًۭا يُفْتَرَىٰ وَلَٰكِن تَصْدِيقَ ٱلَّذِى بَيْنَ يَدَيْهِ '
    'وَتَفْصِيلَ كُلِّ شَىْءٍۢ وَهُدًۭى وَرَحْمَةًۭ لِّقَوْمٍۢ يُؤْمِنُونَ';

const String _kFallbackEn =
    'There was certainly in their stories a lesson for those of '
    'understanding. Never was the Qur’an a narration invented, but a '
    'confirmation of what was before it and a detailed explanation of all '
    'things and guidance and mercy for a people who believe.';

const String _kFallbackFr =
    'Dans leurs récits il y a certes une leçon pour les gens doués '
    'd’intelligence. Ce n’est point là un récit fabriqué. '
    'C’est au contraire la confirmation de ce qui existait déjà avant '
    'lui, un exposé détaillé de toute chose, un guide et une miséricorde '
    'pour des gens qui croient.';

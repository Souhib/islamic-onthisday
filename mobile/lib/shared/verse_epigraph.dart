import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/quran_extracts.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// A centered Qur'anic citation rendered as a section divider.
/// When given ``quranRefs`` from an event/lesson, picks the first
/// surah:ayah from the freeform ref string and looks it up in the
/// pipeline-emitted ``quran-extracts.json``. Falls back to
/// **Yūsuf 12:111** ("there is a lesson for those of understanding")
/// when no refs are supplied or the lookup misses.
class VerseEpigraph extends ConsumerWidget {
  const VerseEpigraph({this.quranRefs, super.key});

  final String? quranRefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final extracts = ref.watch(quranExtractsProvider).value;
    if (extracts == null) return const SizedBox.shrink();

    final verse = extracts.pick(firstQuranKey(quranRefs));
    if (verse == null) return const SizedBox.shrink();

    final translation = switch (lang) {
      'ar' => '',
      'fr' => verse.fr,
      _ => verse.en,
    };
    final surahPrefix = lang == 'ar' ? 'سورة' : 'Sūrat';
    final surahName = lang == 'ar' ? verse.surahNameAr : verse.surahNameEn;
    final ref_ = '${verse.surahNumber}:${verse.ayahNumber}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        children: [
          const FriezeRule(rosetteOnly: true, marginTop: 0, marginBottom: 24),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              verse.ar,
              textAlign: TextAlign.center,
              style: IotdTypography.arabic(size: 22, color: t.ink, height: 1.9),
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
            '${surahPrefix.toUpperCase()} ${surahName.toUpperCase()} · $ref_',
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

import 'package:flutter/material.dart';
import 'package:iotd_mobile/api/generated/models/today_response_secondary_sealed.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// One row in the "More reading for today" stack — a small card with
/// era / category eyebrow, title in serif, and a thin metadata strip
/// (Hijri date / Qur'an refs / hadith refs depending on item kind).
class SecondaryCard extends StatelessWidget {
  const SecondaryCard({required this.item, required this.onTap, super.key});

  final TodayResponseSecondarySealed item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final (eyebrow, title, meta) = _shape(item, lang);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow, color: EyebrowColor.accent),
            const SizedBox(height: 8),
            Text(
              title,
              style: IotdTypography.serif(
                size: 18,
                color: t.ink,
                weight: FontWeight.w500,
                height: 1.15,
                letterSpacing: -0.3,
              ),
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                meta,
                style: IotdTypography.mono(
                  size: 11.5,
                  color: t.inkMute,
                  letterSpacing: 0.6,
                  uppercase: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

(String, String, String) _shape(TodayResponseSecondarySealed item, String lang) {
  if (item is TodayResponseSecondarySealedEventSummary) {
    final title = _pick(lang, item.title, item.titleAr, item.titleFr);
    final meta = [if (item.hijri != null) item.hijri, if (item.gregorian != null) _ddmmyyyy(item.gregorian!)]
        .whereType<String>()
        .join(' · ');
    return (_humanise(item.era ?? 'event'), title, meta);
  }
  if (item is TodayResponseSecondarySealedLessonSummary) {
    final title = _pick(lang, item.title, item.titleAr, item.titleFr);
    return (_humanise(item.category), title, item.reference ?? '');
  }
  return ('', '', '');
}

String _humanise(String slug) => slug.replaceAll('_', ' ');

String _pick(String lang, String en, String? ar, String? fr) => switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

String _ddmmyyyy(String iso) {
  final m = RegExp(r'^(\d{1,4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (m == null) return iso;
  return '${m.group(3)}-${m.group(2)}-${m.group(1)!.padLeft(4, '0')}';
}

import 'package:flutter/material.dart';
import 'package:iotd_mobile/api/generated/models/event_detail_verification_status.dart';
import 'package:iotd_mobile/api/generated/models/today_response.dart';
import 'package:iotd_mobile/api/generated/models/today_response_headline_sealed.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// The hero composition: era eyebrow, verification chip, full-width
/// title (Cormorant Garamond), Arabic companion when the locale is
/// non-Arabic, the dates row (Hijri + Gregorian long + DD-MM-YYYY),
/// and the introduction summary in serif italic.
class HeadlineCard extends StatelessWidget {
  const HeadlineCard({required this.today, required this.onOpen, super.key});

  final TodayResponse today;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final headline = today.headline;
    if (headline == null) {
      return const SizedBox.shrink();
    }

    if (headline is TodayResponseHeadlineSealedEventDetail) {
      final localisedTitle = _pick(lang, headline.title, headline.titleAr, headline.titleFr);
      final localisedSummary =
          _pick(lang, headline.summary, headline.summaryAr, headline.summaryFr);
      final showArabicCompanion = lang != 'ar' && headline.titleAr != null;

      return InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if ((headline.era ?? '').isNotEmpty)
                    Eyebrow(_humanise(headline.era!), color: EyebrowColor.accent),
                  const Spacer(),
                  VerificationChip(
                    kind: _verificationOf(headline.verificationStatus),
                    label: _verificationLabel(i18n, headline.verificationStatus),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                localisedTitle,
                style: IotdTypography.serif(
                  size: 34,
                  color: t.ink,
                  weight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: -0.6,
                ),
              ),
              if (showArabicCompanion) ...[
                const SizedBox(height: 12),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    headline.titleAr!,
                    style: IotdTypography.arabic(
                      size: 22,
                      color: t.inkSoft,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _DatesRow(hijri: headline.hijri, gregorian: headline.gregorian),
              const SizedBox(height: 18),
              FriezeRule(
                label: i18n.today.introduction,
                marginTop: 4,
                marginBottom: 14,
              ),
              Text(
                localisedSummary,
                style: IotdTypography.serif(
                  size: 18,
                  color: t.inkSoft,
                  style: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (headline is TodayResponseHeadlineSealedLessonDetail) {
      final localisedTitle = _pick(lang, headline.title, headline.titleAr, headline.titleFr);
      final localisedSummary =
          _pick(lang, headline.summary, headline.summaryAr, headline.summaryFr);
      return InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Eyebrow(_humanise(headline.category), color: EyebrowColor.accent),
              const SizedBox(height: 16),
              Text(
                localisedTitle,
                style: IotdTypography.serif(
                  size: 34,
                  color: t.ink,
                  weight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 18),
              FriezeRule(
                label: i18n.today.introduction,
                marginTop: 4,
                marginBottom: 14,
              ),
              Text(
                localisedSummary,
                style: IotdTypography.serif(
                  size: 18,
                  color: t.inkSoft,
                  style: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _DatesRow extends StatelessWidget {
  const _DatesRow({required this.hijri, required this.gregorian});

  final String? hijri;
  final String? gregorian;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      children: [
        if (hijri != null)
          Text(
            hijri!,
            style: IotdTypography.serif(
              size: 17,
              color: t.ink,
              style: FontStyle.italic,
            ),
          ),
        if (gregorian != null) ...[
          Text(
            '· ${_longGregorian(gregorian!, Localizations.localeOf(context).languageCode)}',
            style: IotdTypography.serif(
              size: 15,
              color: t.inkSoft,
              style: FontStyle.italic,
            ),
          ),
          Text(
            '· ${_ddmmyyyy(gregorian!)} ·',
            style: IotdTypography.mono(
              size: 12,
              color: t.inkMute,
              letterSpacing: 0.8,
              uppercase: false,
            ),
          ),
        ],
      ],
    );
  }
}

String _pick(String lang, String en, String? ar, String? fr) {
  return switch (lang) {
    'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
    'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
    _ => en,
  };
}

VerificationKind _verificationOf(EventDetailVerificationStatus s) => switch (s) {
      EventDetailVerificationStatus.scholarReviewed => VerificationKind.scholarReviewed,
      EventDetailVerificationStatus.crossVerified => VerificationKind.crossVerified,
      EventDetailVerificationStatus.singleSource => VerificationKind.singleSource,
      _ => VerificationKind.unverified,
    };

String _verificationLabel(Translations i18n, EventDetailVerificationStatus s) => switch (s) {
      EventDetailVerificationStatus.scholarReviewed => i18n.verification.scholar_reviewed,
      EventDetailVerificationStatus.crossVerified => i18n.verification.cross_verified,
      EventDetailVerificationStatus.singleSource => i18n.verification.single_source,
      _ => i18n.verification.unverified,
    };

String _longGregorian(String iso, String lang) {
  final m = RegExp(r'^(\d{1,4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (m == null) return iso;
  final y = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  final months = lang == 'fr'
      ? const ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
          'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre']
      : const ['', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'];
  return '$d ${months[mo]} $y';
}

String _humanise(String slug) => slug.replaceAll('_', ' ');

String _ddmmyyyy(String iso) {
  final m = RegExp(r'^(\d{1,4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (m == null) return iso;
  final y = m.group(1)!.padLeft(4, '0');
  return '${m.group(3)}-${m.group(2)}-$y';
}

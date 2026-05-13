import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/api/generated/models/recent_day_headline_sealed.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/recent/recent_provider.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';

/// Recent days list — the 14 most recent calendar days that produced
/// a headline event. Each row is a tappable card that opens the
/// detail page for that day's hero entry.
class RecentScreen extends ConsumerWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(recentProvider);

    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: query.when(
          loading: () => Center(
            child: Text(
              i18n.today.loading.toUpperCase(),
              style: ThaqafaTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.4),
            ),
          ),
          error: (_, _) => Center(
            child: Text(
              i18n.today.load_failed,
              style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, style: FontStyle.italic),
            ),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(recentProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 60),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Eyebrow(i18n.nav.recent, color: EyebrowColor.accent),
                ),
                const SizedBox(height: 12),
                for (final day in data.days)
                  if (day.headline != null) _RecentRow(day: day),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.day});

  final dynamic day;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final headline = day.headline as RecentDayHeadlineSealed;
    final (eyebrow, title, slug, isLesson) = _shape(headline, lang);

    return InkWell(
      onTap: () => GoRouter.of(context)
          .push('${isLesson ? AppRoutes.lesson : AppRoutes.event}/$slug'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.rule, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${day.calendar.hijri.day} ${day.calendar.hijri.monthShort}',
                  style: ThaqafaTypography.serif(
                    size: 14,
                    color: t.ink,
                    style: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '· ${day.calendar.gregorian.day} ${(day.calendar.gregorian.month as String).substring(0, 3)} ${day.calendar.gregorian.year}',
                  style: ThaqafaTypography.mono(
                    size: 11,
                    color: t.inkMute,
                    letterSpacing: 0.6,
                    uppercase: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Eyebrow(eyebrow, color: EyebrowColor.accent),
            const SizedBox(height: 6),
            Text(
              title,
              style: ThaqafaTypography.serif(
                size: 18,
                color: t.ink,
                weight: FontWeight.w500,
                height: 1.15,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

(String, String, String, bool) _shape(RecentDayHeadlineSealed h, String lang) {
  if (h is RecentDayHeadlineSealedEventDetail) {
    return (
      (h.era ?? 'event').replaceAll('_', ' '),
      _pick(lang, h.title, h.titleAr, h.titleFr),
      h.id,
      false,
    );
  }
  if (h is RecentDayHeadlineSealedLessonDetail) {
    return (
      h.category.replaceAll('_', ' '),
      _pick(lang, h.title, h.titleAr, h.titleFr),
      h.id,
      true,
    );
  }
  return ('', '', '', false);
}

String _pick(String lang, String en, String? ar, String? fr) => switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

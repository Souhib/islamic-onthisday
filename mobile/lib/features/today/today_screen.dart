import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/api/generated/models/today_response.dart';
import 'package:thaqafa/api/generated/models/today_response_headline_sealed.dart';
import 'package:thaqafa/api/generated/models/today_response_secondary_sealed.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/today/today_provider.dart';
import 'package:thaqafa/features/today/widgets/footer.dart';
import 'package:thaqafa/features/today/widgets/headline_card.dart';
import 'package:thaqafa/features/today/widgets/masthead.dart';
import 'package:thaqafa/features/today/widgets/secondary_card.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/thaqafa_mark.dart';
import 'package:thaqafa/shared/verse_epigraph.dart';

/// The Today route — fetches `/api/v1/today`, renders the masthead +
/// headline + secondary stack + Qur'anic epigraph. RefreshIndicator
/// re-pulls when the user pulls down. Loading/Empty/Error states have
/// their own minimal compositions so the editorial vocabulary stays
/// consistent.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: today.when(
          loading: () => const _LoadingState(),
          error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(todayProvider)),
          data: (TodayResponse data) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(todayProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 60),
              children: [
                Masthead(calendar: data.today),
                const SizedBox(height: 18),
                HeadlineCard(today: data),
                if (data.secondary.isNotEmpty) ...[
                  FriezeRule(
                    label: Translations.of(context).today.more_reading,
                    marginTop: 36,
                  ),
                  for (final item in data.secondary)
                    SecondaryCard(
                      item: item,
                      onTap: () => _openSecondary(context, item),
                    ),
                ],
                VerseEpigraph(quranRefs: _headlineQuranRefs(data)),
                const ThaqafaFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _headlineQuranRefs(TodayResponse data) {
    final h = data.headline;
    if (h is TodayResponseHeadlineSealedEventDetail) return h.quranRefs;
    if (h is TodayResponseHeadlineSealedLessonDetail) return h.quranRefs;
    return null;
  }

  void _openSecondary(BuildContext context, TodayResponseSecondarySealed item) {
    if (item is TodayResponseSecondarySealedEventSummary) {
      context.push('${AppRoutes.event}/${item.id}');
    } else if (item is TodayResponseSecondarySealedLessonSummary) {
      context.push('${AppRoutes.lesson}/${item.id}');
    }
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ThaqafaMark(size: 48),
          const SizedBox(height: 24),
          Text(
            i18n.today.loading.toUpperCase(),
            style: ThaqafaTypography.mono(
              size: 11,
              color: t.inkMute,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ThaqafaMark(size: 48),
            const SizedBox(height: 16),
            Text(
              i18n.today.load_failed,
              textAlign: TextAlign.center,
              style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, style: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'retry'.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.accent,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

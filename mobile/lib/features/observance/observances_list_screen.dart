import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/api/generated/models/observance_detail.dart';
import 'package:thaqafa/core/i18n/hijri_months.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/observance/observance_provider.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';

/// Sacred-day list. Sorted by hijri month + day. Each row pushes the
/// observance detail.
class ObservancesListScreen extends ConsumerWidget {
  const ObservancesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(observancesListProvider);

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
          data: (items) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(observancesListProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 60),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Eyebrow(i18n.nav.observances, color: EyebrowColor.accent),
                ),
                const SizedBox(height: 12),
                for (final o in (items.toList()..sort(_byDate))) _Row(observance: o),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

int _byDate(ObservanceDetail a, ObservanceDetail b) {
  final byMonth = a.hijriMonth.compareTo(b.hijriMonth);
  if (byMonth != 0) return byMonth;
  return (a.hijriDay ?? 0).compareTo(b.hijriDay ?? 0);
}

class _Row extends StatelessWidget {
  const _Row({required this.observance});

  final ObservanceDetail observance;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final name = _pickName(observance, lang);
    final description = _pickDescription(observance, lang);
    final dateLabel = observance.hijriDay != null
        ? '${observance.hijriDay} ${hijriMonthsLong[observance.hijriMonth]}'
        : hijriMonthsLong[observance.hijriMonth];

    return InkWell(
      onTap: () => context.push('${AppRoutes.observance}/${observance.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.rule, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel,
              style: ThaqafaTypography.serif(
                size: 14,
                color: t.ink,
                style: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: ThaqafaTypography.serif(
                size: 18,
                color: t.ink,
                weight: FontWeight.w500,
                height: 1.15,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ThaqafaTypography.serif(
                size: 14,
                color: t.inkSoft,
                style: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _pickName(ObservanceDetail o, String lang) => switch (lang) {
      'ar' => (o.nameAr?.isNotEmpty ?? false) ? o.nameAr! : o.nameEn,
      'fr' => (o.nameFr?.isNotEmpty ?? false) ? o.nameFr! : o.nameEn,
      _ => o.nameEn,
    };

String _pickDescription(ObservanceDetail o, String lang) => switch (lang) {
      'ar' => (o.descriptionAr?.isNotEmpty ?? false) ? o.descriptionAr! : o.descriptionEn,
      'fr' => (o.descriptionFr?.isNotEmpty ?? false) ? o.descriptionFr! : o.descriptionEn,
      _ => o.descriptionEn,
    };

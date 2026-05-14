import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/observance_detail.dart';
import 'package:thaqafa/core/i18n/collapse_breaks.dart';
import 'package:thaqafa/core/i18n/hijri_months.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/observance/observance_provider.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/verse_epigraph.dart';

class ObservanceDetailScreen extends ConsumerWidget {
  const ObservanceDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(observanceBySlugProvider(slug));
    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(
        backgroundColor: t.paper,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
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
              i18n.errors.not_found,
              style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, style: FontStyle.italic),
            ),
          ),
          data: (o) => _Body(observance: o),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.observance});

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

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 60),
      children: [
        Eyebrow(i18n.nav.observances, color: EyebrowColor.accent),
        const SizedBox(height: 16),
        Text(
          name,
          style: ThaqafaTypography.serif(
            size: 32,
            color: t.ink,
            weight: FontWeight.w500,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          dateLabel,
          style: ThaqafaTypography.serif(
            size: 17,
            color: t.ink,
            style: FontStyle.italic,
          ),
        ),
        FriezeRule(label: i18n.today.introduction, marginTop: 22, marginBottom: 14),
        Text(
          collapseHardBreaks(description),
          style: ThaqafaTypography.serif(
            size: 19,
            color: t.inkSoft,
            style: FontStyle.italic,
            height: 1.6,
          ),
        ),
        VerseEpigraph(quranRefs: observance.quranRefs),
      ],
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

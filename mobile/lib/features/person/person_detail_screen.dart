import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/person_detail.dart';
import 'package:thaqafa/core/i18n/collapse_breaks.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/person/person_provider.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/verse_epigraph.dart';

/// Person detail page. Shows the localised name, kunya/laqab/nisba
/// when present, the role chip + restricted-figure badges (Prophet
/// / Sahabi / Ahl al-Bayt), an image when policy permits, and the
/// biography.
class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(personBySlugProvider(slug));

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
          data: (person) => _Body(person: person),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.person});

  final PersonDetail person;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final name = lang == 'ar' && (person.fullNameAr ?? '').isNotEmpty
        ? person.fullNameAr!
        : person.fullNameEn;
    final showImage = (person.imageUrl ?? '').isNotEmpty &&
        !person.isProphet &&
        !person.isSahabi &&
        !person.isAhlAlBayt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 60),
      children: [
        Eyebrow(i18n.person.eyebrow, color: EyebrowColor.accent),
        const SizedBox(height: 18),
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
        if (lang != 'ar' && (person.fullNameAr ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              person.fullNameAr!,
              style: ThaqafaTypography.arabic(size: 22, color: t.inkSoft, height: 1.5),
            ),
          ),
        ],
        if ((person.role ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Eyebrow(person.role!, color: EyebrowColor.inkMute),
        ],
        if (person.isProphet || person.isSahabi || person.isAhlAlBayt) ...[
          const SizedBox(height: 12),
          _RestrictedNotice(person: person),
        ],
        if (showImage) ...[
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: t.rule, width: 0.5),
                bottom: BorderSide(color: t.rule, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: CachedNetworkImage(
                imageUrl: person.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: t.paperLo),
                errorWidget: (_, _, _) => Container(color: t.paperLo),
              ),
            ),
          ),
        ],
        if ((person.biography ?? '').isNotEmpty) ...[
          FriezeRule(label: i18n.person.biography, marginTop: 28, marginBottom: 18),
          Text(
            collapseHardBreaks(person.biography!),
            style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, height: 1.65),
          ),
        ],
        const VerseEpigraph(),
      ],
    );
  }
}

class _RestrictedNotice extends StatelessWidget {
  const _RestrictedNotice({required this.person});

  final PersonDetail person;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final reason = person.isProphet
        ? i18n.person.restricted_prophet
        : person.isSahabi
            ? i18n.person.restricted_sahabi
            : i18n.person.restricted_ahl_al_bayt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.warnBg,
        border: Border.all(color: t.warn.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        reason,
        style: ThaqafaTypography.serif(
          size: 14,
          color: t.warn,
          style: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/bookmark_create_target_kind.dart';
import 'package:iotd_mobile/api/generated/models/lesson_detail.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/features/bookmarks/save_button.dart';
import 'package:iotd_mobile/features/lesson/lesson_provider.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';
import 'package:iotd_mobile/shared/verse_epigraph.dart';
import 'package:url_launcher/url_launcher.dart';

/// Single-lesson detail page. Lessons are dateless, so the date strip
/// is replaced by the source reference (e.g. ``Sūrat al-Qasaṣ 28:76``).
class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(lessonBySlugProvider(slug));

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
              style: IotdTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.4),
            ),
          ),
          error: (_, _) => Center(
            child: Text(
              i18n.errors.not_found,
              style: IotdTypography.serif(size: 17, color: t.inkSoft, style: FontStyle.italic),
            ),
          ),
          data: (lesson) => _Body(lesson: lesson),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.lesson});

  final LessonDetail lesson;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final title = _pick(lang, lesson.title, lesson.titleAr, lesson.titleFr);
    final summary = _pick(lang, lesson.summary, lesson.summaryAr, lesson.summaryFr);
    final body = _pickList(lang, lesson.body, lesson.bodyAr, lesson.bodyFr);

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 60),
      children: [
        Row(
          children: [
            Eyebrow(lesson.category, color: EyebrowColor.accent),
            const Spacer(),
            SaveButton(slug: lesson.id, kind: BookmarkCreateTargetKind.lesson),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: IotdTypography.serif(
            size: 34,
            color: t.ink,
            weight: FontWeight.w500,
            height: 1.0,
            letterSpacing: -0.6,
          ),
        ),
        if (lang != 'ar' && (lesson.titleAr ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              lesson.titleAr!,
              style: IotdTypography.arabic(size: 22, color: t.inkSoft, height: 1.5),
            ),
          ),
        ],
        if ((lesson.reference ?? '').isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            lesson.reference!,
            style: IotdTypography.mono(
              size: 12,
              color: t.inkMute,
              letterSpacing: 0.8,
              uppercase: false,
            ),
          ),
        ],
        const SizedBox(height: 16),
        FriezeRule(label: i18n.today.introduction, marginTop: 4, marginBottom: 14),
        Text(
          summary,
          style: IotdTypography.serif(
            size: 18,
            color: t.inkSoft,
            style: FontStyle.italic,
            height: 1.6,
          ),
        ),
        if (body.isNotEmpty) ...[
          FriezeRule(label: i18n.today.the_reading, marginTop: 28, marginBottom: 18),
          for (int i = 0; i < body.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 18),
              child: Text(
                body[i],
                style: IotdTypography.serif(size: 17, color: t.inkSoft, height: 1.65),
              ),
            ),
          const FriezeRule(rosetteOnly: true, marginTop: 28),
          Text(
            i18n.today.end_of_reading.toUpperCase(),
            textAlign: TextAlign.center,
            style: IotdTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.6),
          ),
        ],
        if ((lesson.sourceUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: () => launchUrl(
                Uri.parse(lesson.sourceUrl!),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                '${i18n.today.verify.toUpperCase()} ↗',
                style: IotdTypography.mono(
                  size: 11,
                  color: t.accent,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
        ],
        VerseEpigraph(quranRefs: lesson.quranRefs),
      ],
    );
  }
}

String _pick(String lang, String en, String? ar, String? fr) => switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

List<String> _pickList(String lang, List<String> en, List<String>? ar, List<String>? fr) =>
    switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

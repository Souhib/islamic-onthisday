import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/api/generated/models/bookmark_out.dart';
import 'package:thaqafa/api/generated/models/bookmark_out_target_kind.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/bookmarks/bookmarks_provider.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/thaqafa_mark.dart';

/// User's saved-for-later list. Reads ``BookmarksNotifier``; tapping
/// a row pushes the matching event/lesson detail.
class BookmarksListScreen extends ConsumerWidget {
  const BookmarksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(bookmarksProvider);

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
              i18n.today.load_failed,
              style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, style: FontStyle.italic),
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookmarksProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 60),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Eyebrow(i18n.bookmarks.title, color: EyebrowColor.accent),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 80, 28, 0),
                    child: Column(
                      children: [
                        const ThaqafaMark(size: 48),
                        const SizedBox(height: 18),
                        Text(
                          i18n.bookmarks.empty,
                          textAlign: TextAlign.center,
                          style: ThaqafaTypography.serif(
                            size: 17,
                            color: t.inkSoft,
                            style: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final b in items) _BookmarkRow(bookmark: b),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({required this.bookmark});

  final BookmarkOut bookmark;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final title = _pickTitle(bookmark, lang);
    final isLesson = bookmark.targetKind == BookmarkOutTargetKind.lesson;

    return InkWell(
      onTap: () => GoRouter.of(context).push(
        '${isLesson ? AppRoutes.lesson : AppRoutes.event}/${bookmark.targetSlug}',
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.rule, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(
              isLesson ? i18n.nav.recent : 'event',
              color: EyebrowColor.accent,
            ),
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

String _pickTitle(BookmarkOut b, String lang) => switch (lang) {
      'ar' => (b.targetTitleAr?.isNotEmpty ?? false) ? b.targetTitleAr! : (b.targetTitle ?? b.targetSlug),
      'fr' => (b.targetTitleFr?.isNotEmpty ?? false) ? b.targetTitleFr! : (b.targetTitle ?? b.targetSlug),
      _ => b.targetTitle ?? b.targetSlug,
    };

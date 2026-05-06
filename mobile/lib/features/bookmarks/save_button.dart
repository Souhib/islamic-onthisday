import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/generated/models/bookmark_create_target_kind.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/features/auth/auth_provider.dart';
import 'package:iotd_mobile/features/auth/auth_state.dart';
import 'package:iotd_mobile/features/bookmarks/bookmarks_provider.dart';

/// Bookmark toggle. Hidden entirely when the user is anonymous —
/// matches the web's behaviour after the recent change. When signed
/// in, taps are optimistic (state flips immediately, network call in
/// the background; rollback on failure is delegated to the notifier).
class SaveButton extends ConsumerWidget {
  const SaveButton({required this.slug, required this.kind, super.key});

  final String slug;
  final BookmarkCreateTargetKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).value;
    if (auth is! AuthSignedIn) return const SizedBox.shrink();

    final t = context.tokens;
    final notifier = ref.watch(bookmarksProvider.notifier);
    final saved = ref.watch(bookmarksProvider).maybeWhen(
          data: (_) => notifier.isBookmarked(slug),
          orElse: () => false,
        );

    return InkWell(
      onTap: () async {
        if (saved) {
          await notifier.remove(slug);
        } else {
          await notifier.add(slug: slug, kind: kind);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: saved ? t.ink : Colors.transparent,
          border: Border.all(color: saved ? t.ink : t.rule, width: 0.5),
        ),
        child: Text(
          (saved ? 'saved' : 'save').toUpperCase(),
          style: IotdTypography.mono(
            size: 10.5,
            color: saved ? t.paper : t.inkSoft,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

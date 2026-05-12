import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/auth/auth_provider.dart';
import 'package:thaqafa/features/auth/auth_state.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';

/// Account section embedded in Settings. Shows the signed-in user's
/// email + display name with a `Sign out` action, or a `Sign in /
/// Sign up` pair when anonymous.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final auth = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FriezeRule(label: i18n.auth.account, marginTop: 4, marginBottom: 14),
        auth.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(child: SizedBox.shrink()),
          ),
          error: (_, _) => Text(
            i18n.errors.generic,
            style: ThaqafaTypography.serif(size: 14, color: t.warn, style: FontStyle.italic),
          ),
          data: (state) => switch (state) {
            AuthSignedIn(:final user) => _SignedInRow(
                email: user.email,
                displayName: user.displayName ?? '—',
                onLogout: () => ref.read(authProvider.notifier).logout(),
              ),
            _ => _AnonymousRow(
                onSignIn: () => context.push(AppRoutes.signIn),
                onSignUp: () => context.push(AppRoutes.signUp),
              ),
          },
        ),
      ],
    );
  }
}

class _SignedInRow extends ConsumerWidget {
  const _SignedInRow({
    required this.email,
    required this.displayName,
    required this.onLogout,
  });

  final String email;
  final String displayName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: ThaqafaTypography.serif(size: 18, color: t.ink, weight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: ThaqafaTypography.mono(
                  size: 12,
                  color: t.inkMute,
                  letterSpacing: 0.4,
                  uppercase: false,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onLogout,
                  child: Text(
                    i18n.auth.sign_out.toUpperCase(),
                    style: ThaqafaTypography.mono(
                      size: 11,
                      color: t.warn,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => context.push(AppRoutes.bookmarks),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    i18n.bookmarks.title.toUpperCase(),
                    style: ThaqafaTypography.mono(
                      size: 11,
                      color: t.inkSoft,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                Text('↗', style: ThaqafaTypography.mono(size: 14, color: t.accent)),
              ],
            ),
          ),
        ),
        // Delete-account section — explicit "danger zone" with its own
        // frieze + warning text so the entry point is obvious to anyone
        // scrolling through Settings (including App Review reviewers
        // checking for the deletion option Apple requires).
        FriezeRule(
          label: i18n.auth.delete_account_title,
          marginTop: 24,
          marginBottom: 12,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            i18n.auth.delete_account_warning,
            style: ThaqafaTypography.serif(
              size: 15,
              color: t.inkSoft,
              style: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () => _confirmDelete(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: t.warn,
            side: BorderSide(color: t.warn, width: 1),
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            i18n.auth.delete_account_cta.toUpperCase(),
            style: ThaqafaTypography.mono(
              size: 12,
              color: t.warn,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.paper,
        shape: const RoundedRectangleBorder(),
        title: Text(
          i18n.auth.delete_account_title,
          style: ThaqafaTypography.serif(
            size: 22,
            color: t.ink,
            weight: FontWeight.w500,
          ),
        ),
        content: Text(
          i18n.auth.delete_account_warning,
          style: ThaqafaTypography.serif(
            size: 15,
            color: t.inkSoft,
            style: FontStyle.italic,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              i18n.auth.delete_account_cancel.toUpperCase(),
              style: ThaqafaTypography.mono(
                size: 11,
                color: t.inkMute,
                letterSpacing: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              i18n.auth.delete_account_confirm.toUpperCase(),
              style: ThaqafaTypography.mono(
                size: 11,
                color: t.warn,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(authProvider.notifier).deleteAccount();
    } catch (_) {
      // notifier transitions to error; UI listening to authProvider handles
      // re-rendering. Nothing else to do here.
    }
  }
}

class _AnonymousRow extends StatelessWidget {
  const _AnonymousRow({required this.onSignIn, required this.onSignUp});

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSignIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: t.ink,
              side: BorderSide(color: t.rule, width: 0.5),
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              i18n.auth.sign_in.toUpperCase(),
              style: ThaqafaTypography.mono(size: 11, color: t.ink, letterSpacing: 1.4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: t.ink,
              foregroundColor: t.paper,
              elevation: 0,
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              i18n.auth.sign_up.toUpperCase(),
              style: ThaqafaTypography.mono(size: 11, color: t.paper, letterSpacing: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

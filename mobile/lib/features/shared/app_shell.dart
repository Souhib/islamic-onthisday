import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/thaqafa_mark.dart';

/// Shell wrapping the three top-level routes (Recent / Sacred days /
/// Settings) with a custom mono-uppercase bottom navigation bar.
///
/// Today is intentionally NOT a bottom-nav destination — it's the
/// app's home and lands by default. From Recent / Sacred days /
/// Settings, the eight-point star at the top-left is a "go home"
/// affordance back to Today. This keeps the bottom nav at 3 cells
/// (no wrap) and leans into the editorial DNA: Today *is* the app,
/// not just a tab.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final showHomeBar = location != AppRoutes.today;

    return Scaffold(
      backgroundColor: t.paper,
      body: Column(
        children: [
          if (showHomeBar) const _HomeBar(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: t.paper,
            border: Border(top: BorderSide(color: t.rule, width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 52,
          child: Row(
            children: [
              _NavItem(
                label: i18n.nav.recent,
                active: location == AppRoutes.recent,
                onTap: () => GoRouter.of(context).go(AppRoutes.recent),
              ),
              _NavItem(
                label: i18n.nav.observances,
                active: location == AppRoutes.observances,
                onTap: () => GoRouter.of(context).go(AppRoutes.observances),
              ),
              _NavItem(
                label: i18n.nav.settings,
                active: location == AppRoutes.settings,
                onTap: () => GoRouter.of(context).go(AppRoutes.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return SafeArea(
      bottom: false,
      child: InkWell(
        onTap: () => GoRouter.of(context).go(AppRoutes.today),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.rule, width: 0.5)),
          ),
          child: Row(
            children: [
              // Use Material's directional back icon — Flutter auto-flips
              // it in RTL contexts (← becomes → for Arabic), so the
              // affordance always points "back along the reading flow".
              Icon(
                Icons.arrow_back,
                size: 18,
                color: t.accent,
                textDirection: Directionality.of(context),
              ),
              const SizedBox(width: 12),
              const ThaqafaMark(size: 22),
              const SizedBox(width: 12),
              Text(
                i18n.nav.today.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.accent,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: ThaqafaTypography.mono(
                size: 11,
                color: active ? t.ink : t.inkMute,
                weight: active ? FontWeight.w500 : FontWeight.w400,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

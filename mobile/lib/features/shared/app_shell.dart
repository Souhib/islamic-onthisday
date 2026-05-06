import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iotd_mobile/core/router/app_router.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';

/// Shell wrapping the three top-level routes (Today / Recent /
/// Settings) with a custom mono-uppercase bottom navigation bar — the
/// stock Material `NavigationBar` reads too app-y for this product.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: t.paper,
      body: child,
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
                label: i18n.nav.today,
                active: location == AppRoutes.today,
                onTap: () => GoRouter.of(context).go(AppRoutes.today),
              ),
              _NavItem(
                label: i18n.nav.recent,
                active: location == AppRoutes.recent,
                onTap: () => GoRouter.of(context).go(AppRoutes.recent),
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
              style: IotdTypography.mono(
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

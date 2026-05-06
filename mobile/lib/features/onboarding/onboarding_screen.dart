import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotd_mobile/core/di/providers.dart';
import 'package:iotd_mobile/core/router/app_router.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// First-launch welcome screen. One step (per the design): the project's
/// promise in a single sentence + a `Begin` button. The user-facing
/// preferences (calendar order, image policy) live elsewhere — we don't
/// gate the reading experience behind a setup gauntlet.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 36),
          child: Column(
            children: [
              // Top mark — eight-point star + colophon eyebrow.
              Column(
                children: [
                  const EightPointStar(size: 44),
                  const SizedBox(height: 18),
                  Text(
                    i18n.onboarding.eyebrow.toUpperCase(),
                    style: IotdTypography.mono(
                      size: 11,
                      color: t.accent,
                      letterSpacing: 2.6,
                    ),
                  ),
                ],
              ),

              // Centred promise — frieze rosette top + bottom for editorial weight.
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FriezeRule(rosetteOnly: true, marginBottom: 28),
                      Text(
                        i18n.onboarding.headline,
                        textAlign: TextAlign.center,
                        style: IotdTypography.serif(
                          size: 38,
                          color: t.ink,
                          weight: FontWeight.w500,
                          height: 1.05,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        i18n.onboarding.subhead,
                        textAlign: TextAlign.center,
                        style: IotdTypography.serif(
                          size: 17,
                          color: t.inkSoft,
                          style: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      const FriezeRule(rosetteOnly: true, marginTop: 28),
                    ],
                  ),
                ),
              ),

              // Begin — full-width inverted button.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('onboarding_begin_button'),
                  onPressed: () async {
                    await ref
                        .read<OnboardingNotifier>(onboardingProvider.notifier)
                        .complete();
                    if (context.mounted) context.go(AppRoutes.today);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.ink,
                    foregroundColor: t.paper,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    i18n.onboarding.begin.toUpperCase(),
                    style: IotdTypography.mono(
                      size: 12,
                      color: t.paper,
                      letterSpacing: 1.6,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

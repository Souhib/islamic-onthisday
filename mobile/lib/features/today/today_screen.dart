import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';
import 'package:iotd_mobile/shared/verse_epigraph.dart';

/// Placeholder Today screen — the real implementation arrives in
/// phase 1 (TanStack-equivalent fetch + headline + rails + epigraph).
/// For now it just proves the theme + i18n + navigation pipeline.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EightPointStar(size: 36),
                const SizedBox(height: 24),
                const Eyebrow('today', color: EyebrowColor.accent),
                const SizedBox(height: 12),
                Text(
                  i18n.app.tagline,
                  textAlign: TextAlign.center,
                  style: IotdTypography.serif(
                    size: 26,
                    color: t.ink,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                VerseEpigraph.fallback(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

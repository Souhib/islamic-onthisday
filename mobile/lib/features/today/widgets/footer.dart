import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/api/dataset_meta.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';

/// Minimal footer at the end of the Today scroll: dataset depth +
/// version. Mirrors the web's footer composition without the
/// /about link (that lives in Settings on mobile).
class ThaqafaFooter extends ConsumerWidget {
  const ThaqafaFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final meta = ref.watch(datasetMetaProvider).value;
    if (meta == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.rule, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${_format(meta.eventCount)} EVENTS · ${meta.observanceCount} SACRED DAYS · ${meta.daysWithHeadline}/366 DAYS COVERED',
            textAlign: TextAlign.center,
            style: ThaqafaTypography.mono(
              size: 9.5,
              color: t.inkMute,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => context.push(AppRoutes.about),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${i18n.about.created_by.toUpperCase()} SOUHIB TRABELSI',
                style: ThaqafaTypography.mono(
                  size: 9.5,
                  color: t.ink,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '0.1.0 · 1447 AH BUILD',
            style: ThaqafaTypography.mono(
              size: 9,
              color: t.inkFaint,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

String _format(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/api/dataset_meta.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';

/// Minimal footer at the end of the Today scroll: dataset depth +
/// version. Mirrors the web's footer composition without the
/// /about link (that lives in Settings on mobile).
class IotdFooter extends ConsumerWidget {
  const IotdFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
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
            style: IotdTypography.mono(
              size: 9.5,
              color: t.inkMute,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '0.1.0 · 1447 AH BUILD',
            style: IotdTypography.mono(
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

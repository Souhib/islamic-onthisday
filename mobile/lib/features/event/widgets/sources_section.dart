import 'package:flutter/material.dart';
import 'package:thaqafa/api/generated/models/source_ref.dart';
import 'package:thaqafa/api/generated/models/source_ref_kind.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';

/// List of source references attached to an event. Each row is the
/// source label (e.g. "al-Bidaya wa'l-Nihaya") with a small mono-cap
/// tier chip below ("classical" / "primary" / "academic" /
/// "secondary"), matching the web's posture.
class SourcesSection extends StatelessWidget {
  const SourcesSection({required this.sources, super.key});

  final List<SourceRef> sources;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FriezeRule(label: i18n.event.sources, marginTop: 28, marginBottom: 14),
        for (final s in sources)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.rule, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.label,
                  style: ThaqafaTypography.serif(
                    size: 17,
                    color: t.ink,
                    weight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _kindLabel(i18n, s.kind).toUpperCase(),
                  style: ThaqafaTypography.mono(
                    size: 10,
                    color: t.inkMute,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _kindLabel(Translations i18n, SourceRefKind kind) => switch (kind) {
      SourceRefKind.classical => i18n.event.source_classical,
      SourceRefKind.primary => i18n.event.source_primary,
      SourceRefKind.modern => i18n.event.source_modern,
      _ => '',
    };

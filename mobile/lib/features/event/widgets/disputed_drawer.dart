import 'package:flutter/material.dart';
import 'package:iotd_mobile/api/generated/models/disputed_position.dart';
import 'package:iotd_mobile/api/generated/models/disputed_position_weight.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// Modal bottom sheet showing every attested position when an event
/// is `disputed: true`. Tier ladder per row: majority / minority /
/// rare. Mirrors the web's `DisputedDrawer`.
Future<void> showDisputedDrawer(
  BuildContext context, {
  required List<DisputedPosition> positions,
  required String aboutLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).extension<IotdTokens>()!.paper,
    shape: const RoundedRectangleBorder(),
    builder: (ctx) => _DisputedDrawerBody(
      positions: positions,
      aboutLabel: aboutLabel,
    ),
  );
}

class _DisputedDrawerBody extends StatelessWidget {
  const _DisputedDrawerBody({
    required this.positions,
    required this.aboutLabel,
  });

  final List<DisputedPosition> positions;
  final String aboutLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final sorted = [...positions]..sort((a, b) => a.rank.compareTo(b.rank));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: t.rule,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Eyebrow(aboutLabel, color: EyebrowColor.warn),
            const SizedBox(height: 10),
            Text(
              i18n.event.disputed_drawer_title,
              style: IotdTypography.serif(
                size: 26,
                color: t.ink,
                weight: FontWeight.w500,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              i18n.event.disputed_drawer_intro,
              style: IotdTypography.serif(
                size: 16,
                color: t.inkSoft,
                style: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            for (final p in sorted) _PositionRow(position: p),
          ],
        ),
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  const _PositionRow({required this.position});

  final DisputedPosition position;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.rule, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                position.value,
                style: IotdTypography.serif(
                  size: 18,
                  color: t.ink,
                  weight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _weightLabel(i18n, position.weight).toUpperCase(),
                style: IotdTypography.mono(
                  size: 10,
                  color: position.weight == DisputedPositionWeight.primary
                      ? t.accent
                      : t.inkMute,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            position.scholars,
            style: IotdTypography.mono(
              size: 12,
              color: t.inkMute,
              letterSpacing: 0.4,
              uppercase: false,
            ),
          ),
        ],
      ),
    );
  }
}

String _weightLabel(Translations i18n, DisputedPositionWeight w) =>
    switch (w) {
      DisputedPositionWeight.primary => i18n.event.weight_primary,
      DisputedPositionWeight.notable => i18n.event.weight_notable,
      DisputedPositionWeight.minority => i18n.event.weight_minority,
      _ => '',
    };

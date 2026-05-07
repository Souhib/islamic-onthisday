import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/api/generated/models/person_ref.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';

/// Tap-through list of people linked to an event. Each row shows
/// the localised name + the role chip ("subject" / "narrator" /
/// "successor" / etc.) and pushes the person detail page.
class PeopleSection extends StatelessWidget {
  const PeopleSection({required this.people, super.key});

  final List<PersonRef> people;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    if (people.isEmpty) return const SizedBox.shrink();
    final lang = i18n.$meta.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FriezeRule(label: i18n.event.people, marginTop: 28, marginBottom: 14),
        for (final p in people)
          InkWell(
            onTap: () => context.push('${AppRoutes.person}/${p.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: t.rule, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pickName(p, lang),
                          style: ThaqafaTypography.serif(
                            size: 17,
                            color: t.ink,
                            weight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        if ((p.role ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            p.role!.toUpperCase(),
                            style: ThaqafaTypography.mono(
                              size: 10,
                              color: t.inkMute,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '↗',
                    style: ThaqafaTypography.mono(
                      size: 14,
                      color: t.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _pickName(PersonRef p, String lang) => switch (lang) {
      'ar' => (p.nameAr?.isNotEmpty ?? false) ? p.nameAr! : p.name,
      'fr' => (p.nameFr?.isNotEmpty ?? false) ? p.nameFr! : p.name,
      _ => p.name,
    };

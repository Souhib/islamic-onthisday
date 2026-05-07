import 'package:flutter/material.dart';
import 'package:thaqafa/api/generated/models/today_calendar.dart';
import 'package:thaqafa/core/i18n/weekday.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';

/// Compact masthead for the Today screen — eight-point star left,
/// Hijri date right, mono-cap eyebrow centred underneath. Same role
/// as the web's `Masthead` but tightened for a phone viewport.
class Masthead extends StatelessWidget {
  const Masthead({required this.calendar, super.key});

  final TodayCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final lang = TranslationProvider.of(context).flutterLocale.languageCode;
    final hijri = calendar.hijri;
    final greg = calendar.gregorian;
    final weekday = localiseWeekday(greg.weekday, lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const EightPointStar(size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '· $weekday · ${hijri.day} ${hijri.month} ${hijri.year} ah ·',
                  style: ThaqafaTypography.mono(
                    size: 10.5,
                    color: t.inkSoft,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

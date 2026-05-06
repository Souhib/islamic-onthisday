import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/services/app_settings.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';

/// Settings — theme + language + (later) notifications. Each row is a
/// horizontal pair of segmented chips so the editorial vocabulary stays
/// consistent rather than reaching for Material's switch / dropdown.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 60),
          children: [
            Eyebrow(i18n.settings.title, color: EyebrowColor.accent),
            const SizedBox(height: 24),
            FriezeRule(label: i18n.settings.appearance, marginTop: 4, marginBottom: 14),
            _SegmentRow<ThemeMode>(
              options: [
                (ThemeMode.light, i18n.settings.theme_light),
                (ThemeMode.dark, i18n.settings.theme_dark),
                (ThemeMode.system, i18n.settings.theme_system),
              ],
              value: mode,
              onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
            ),
            const SizedBox(height: 18),
            FriezeRule(label: i18n.settings.language, marginTop: 4, marginBottom: 14),
            _SegmentRow<AppLocale?>(
              options: const [
                (AppLocale.en, 'English'),
                (AppLocale.fr, 'Français'),
                (AppLocale.ar, 'العربية'),
              ],
              value: locale,
              onChanged: (l) => ref.read(localeProvider.notifier).set(l),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentRow<T> extends StatelessWidget {
  const _SegmentRow({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: t.rule, width: 0.5),
      ),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            Expanded(
              child: InkWell(
                onTap: () => onChanged(options[i].$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: options[i].$1 == value ? t.ink : t.paper,
                  child: Center(
                    child: Text(
                      options[i].$2.toUpperCase(),
                      style: IotdTypography.mono(
                        size: 11,
                        color: options[i].$1 == value ? t.paper : t.inkSoft,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (i < options.length - 1)
              Container(width: 0.5, height: 44, color: t.rule),
          ],
        ],
      ),
    );
  }
}

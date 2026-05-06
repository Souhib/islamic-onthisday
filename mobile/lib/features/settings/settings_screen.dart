import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/services/app_settings.dart';
import 'package:iotd_mobile/core/services/notifications_provider.dart';
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
    final notifsEnabled = ref.watch(notificationsEnabledProvider);
    final notifHour = ref.watch(notificationHourProvider);

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
            const SizedBox(height: 18),
            FriezeRule(
              label: i18n.settings.notifications,
              marginTop: 4,
              marginBottom: 14,
            ),
            _ToggleRow(
              label: i18n.settings.notifications,
              value: notifsEnabled,
              onChanged: (v) => ref
                  .read(notificationsEnabledProvider.notifier)
                  .set(
                    v,
                    title: i18n.settings.notification_title,
                    body: i18n.settings.notification_body,
                  ),
            ),
            if (notifsEnabled) ...[
              const SizedBox(height: 12),
              _HourPicker(
                value: notifHour,
                label: i18n.settings.notification_time,
                onChanged: (h) => ref
                    .read(notificationHourProvider.notifier)
                    .set(
                      h,
                      title: i18n.settings.notification_title,
                      body: i18n.settings.notification_body,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: IotdTypography.mono(
                  size: 11,
                  color: t.inkSoft,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value ? t.ink : t.paperLo,
                border: Border.all(color: t.rule, width: 0.5),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 140),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  color: value ? t.paper : t.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourPicker extends StatelessWidget {
  const _HourPicker({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Text(
                  label.toUpperCase(),
                  style: IotdTypography.mono(
                    size: 10.5,
                    color: t.inkMute,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                Text(
                  '${value.toString().padLeft(2, '0')}:00',
                  style: IotdTypography.serif(
                    size: 22,
                    color: t.ink,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: t.ink,
              inactiveTrackColor: t.rule,
              thumbColor: t.ink,
              overlayColor: t.ink.withValues(alpha: 0.06),
              trackHeight: 1.5,
            ),
            child: Slider(
              min: 0,
              max: 23,
              divisions: 23,
              value: value.toDouble(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
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

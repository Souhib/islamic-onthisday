import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotd_mobile/core/router/app_router.dart';
import 'package:iotd_mobile/core/services/app_settings.dart';
import 'package:iotd_mobile/core/services/notifications_provider.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/features/auth/account_section.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
    // Highlight the *resolved* locale even when the user hasn't
    // picked one explicitly (the prefs are still null but the app
    // is rendering in some language). Falls back to the device locale.
    final saved = ref.watch(localeProvider);
    final activeLocale = saved ??
        switch (TranslationProvider.of(context).flutterLocale.languageCode) {
          'fr' => AppLocale.fr,
          'ar' => AppLocale.ar,
          _ => AppLocale.en,
        };
    final notifsEnabled = ref.watch(notificationsEnabledProvider);
    final notifTime = ref.watch(notificationTimeProvider);

    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 60),
          children: [
            Eyebrow(i18n.settings.title, color: EyebrowColor.accent),
            const SizedBox(height: 24),
            const AccountSection(),
            const SizedBox(height: 18),
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
              value: activeLocale,
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
              _TimePickerRow(
                value: notifTime,
                label: i18n.settings.notification_time,
                onChanged: (newTime) => ref
                    .read(notificationTimeProvider.notifier)
                    .set(
                      newTime,
                      title: i18n.settings.notification_title,
                      body: i18n.settings.notification_body,
                    ),
              ),
            ],
            const SizedBox(height: 30),
            InkWell(
              onTap: () => context.push(AppRoutes.about),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        i18n.settings.about.toUpperCase(),
                        style: IotdTypography.mono(
                          size: 11,
                          color: t.inkSoft,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      '↗',
                      style: IotdTypography.mono(size: 14, color: t.accent),
                    ),
                  ],
                ),
              ),
            ),
            // Debug-only crash trigger. Verifies the GlitchTip pipeline is
            // wired end-to-end before each release without exposing the
            // tile to end users. Tap "throw" to fire a sync exception
            // (caught by ``FlutterError.onError``); tap "async" for a
            // future error (caught by ``PlatformDispatcher.onError``).
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              const _DebugCrashRow(),
            ],
          ],
        ),
      ),
    );
  }
}

class _DebugCrashRow extends StatelessWidget {
  const _DebugCrashRow();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'DEBUG · GLITCHTIP TEST',
              style: IotdTypography.mono(
                size: 11,
                color: t.warn,
                letterSpacing: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              throw StateError('[iotd] sync crash test');
            },
            child: Text(
              'throw',
              style: IotdTypography.mono(size: 12, color: t.warn, letterSpacing: 1.4),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1));
              throw StateError('[iotd] async crash test');
            },
            child: Text(
              'async',
              style: IotdTypography.mono(size: 12, color: t.warn, letterSpacing: 1.4),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Sentry.captureMessage('[iotd] manual ping from settings');
            },
            child: Text(
              'ping',
              style: IotdTypography.mono(size: 12, color: t.accent, letterSpacing: 1.4),
            ),
          ),
        ],
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

class _TimePickerRow extends StatelessWidget {
  const _TimePickerRow({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final TimeOfDay value;
  final String label;
  final ValueChanged<TimeOfDay> onChanged;

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _open(BuildContext context) async {
    final t = context.tokens;
    var current = value;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.paper,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) => SafeArea(
        top: false,
        child: SizedBox(
          height: 280,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: t.rule, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: IotdTypography.mono(
                        size: 11,
                        color: t.inkMute,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'OK',
                        style: IotdTypography.mono(
                          size: 12,
                          color: t.accent,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: IotdTypography.serif(
                        size: 22,
                        color: t.ink,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    minuteInterval: 1,
                    initialDateTime: DateTime(2026, 1, 1, value.hour, value.minute),
                    onDateTimeChanged: (dt) {
                      current = TimeOfDay(hour: dt.hour, minute: dt.minute);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (current != value) onChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
        child: Row(
          children: [
            Text(
              label.toUpperCase(),
              style: IotdTypography.mono(
                size: 11,
                color: t.inkMute,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Text(
              _format(value),
              style: IotdTypography.serif(
                size: 22,
                color: t.ink,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '↗',
              style: IotdTypography.mono(size: 14, color: t.accent),
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

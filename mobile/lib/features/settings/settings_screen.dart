import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/core/notifications/notification_service.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/services/app_settings.dart';
import 'package:thaqafa/core/services/notifications_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/auth/account_section.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
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
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 60),
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
            FriezeRule(label: i18n.settings.reading_size, marginTop: 4, marginBottom: 14),
            _SegmentRow<double>(
              options: [
                (0.85, i18n.settings.reading_size_s),
                (1.0, i18n.settings.reading_size_m),
                (1.15, i18n.settings.reading_size_l),
                (1.3, i18n.settings.reading_size_xl),
              ],
              value: ref.watch(readingScaleProvider),
              onChanged: (v) => ref.read(readingScaleProvider.notifier).set(v),
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
              const SizedBox(height: 12),
              const _NotifTestRow(),
              const _NotifPermissionBanner(),
            ],
            const SizedBox(height: 30),
            InkWell(
              onTap: () => context.push(AppRoutes.observances),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        i18n.settings.observances_link.toUpperCase(),
                        style: ThaqafaTypography.mono(
                          size: 11,
                          color: t.inkSoft,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      '↗',
                      style: ThaqafaTypography.mono(size: 14, color: t.accent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
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
                        style: ThaqafaTypography.mono(
                          size: 11,
                          color: t.inkSoft,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      '↗',
                      style: ThaqafaTypography.mono(size: 14, color: t.accent),
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
            //
            // ``HIDE_DEBUG_TILE`` lets us capture clean App Store
            // screenshots from a debug build (iOS sim doesn't support
            // release/profile, so it's the only way) without permanently
            // gating the row on a release flag. Pass via:
            //   flutter run --dart-define=HIDE_DEBUG_TILE=true
            if (kDebugMode &&
                !const bool.fromEnvironment('HIDE_DEBUG_TILE')) ...[
              const SizedBox(height: 24),
              const _DebugCrashRow(),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Send a test notification" entry — fires a one-shot 5 seconds out.
/// The main reason it exists is verification: when the user toggles
/// notifications on but never sees one (Focus mode, OS permission
/// denied silently, scheduling bug…) this button collapses the
/// debugging loop into "tap, count to five".
class _NotifTestRow extends ConsumerWidget {
  const _NotifTestRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return InkWell(
      onTap: () async {
        await NotificationService.instance.sendTestNotification(
          title: i18n.settings.notification_test_title,
          body: i18n.settings.notification_test_body,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: t.ink,
              content: Text(
                i18n.settings.notification_test_pending,
                style: ThaqafaTypography.serif(size: 14, color: t.paper),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                i18n.settings.notification_test.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.inkSoft,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Text('↻', style: ThaqafaTypography.mono(size: 14, color: t.accent)),
          ],
        ),
      ),
    );
  }
}

/// Banner shown when the in-app notifications toggle is ON but the OS
/// itself has notifications blocked. Polls ``hasPermission`` once on
/// build — that's enough for a Settings screen where the user is
/// already attentive.
class _NotifPermissionBanner extends ConsumerStatefulWidget {
  const _NotifPermissionBanner();

  @override
  ConsumerState<_NotifPermissionBanner> createState() =>
      _NotifPermissionBannerState();
}

class _NotifPermissionBannerState
    extends ConsumerState<_NotifPermissionBanner> {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final granted = await NotificationService.instance.hasPermission();
    if (mounted) setState(() => _granted = granted);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    if (_granted != false) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.warnBg,
          border: Border.all(color: t.warn.withValues(alpha: 0.5), width: 0.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i18n.settings.notification_permission_warning,
              style: ThaqafaTypography.serif(size: 14, color: t.inkSoft, height: 1.45),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => launchUrl(Uri.parse('app-settings:')),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                i18n.settings.notification_open_system_settings.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.warn,
                  letterSpacing: 1.4,
                ),
              ),
            ),
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
              style: ThaqafaTypography.mono(
                size: 11,
                color: t.warn,
                letterSpacing: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              throw StateError('[thaqafa] sync crash test');
            },
            child: Text(
              'throw',
              style: ThaqafaTypography.mono(size: 12, color: t.warn, letterSpacing: 1.4),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 1));
              throw StateError('[thaqafa] async crash test');
            },
            child: Text(
              'async',
              style: ThaqafaTypography.mono(size: 12, color: t.warn, letterSpacing: 1.4),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Sentry.captureMessage('[thaqafa] manual ping from settings');
            },
            child: Text(
              'ping',
              style: ThaqafaTypography.mono(size: 12, color: t.accent, letterSpacing: 1.4),
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
                style: ThaqafaTypography.mono(
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
                      style: ThaqafaTypography.mono(
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
                        style: ThaqafaTypography.mono(
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
                      dateTimePickerTextStyle: ThaqafaTypography.serif(
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
              style: ThaqafaTypography.mono(
                size: 11,
                color: t.inkMute,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Text(
              _format(value),
              style: ThaqafaTypography.serif(
                size: 22,
                color: t.ink,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '↗',
              style: ThaqafaTypography.mono(size: 14, color: t.accent),
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
    // Segment rows are *controls*, not reading content — pin them at
    // 1.0 even when the global reading-size preset is XL, so the labels
    // don't overflow their cells. The reading body still scales.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
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
                        style: ThaqafaTypography.mono(
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
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/core/di/providers.dart';
import 'package:thaqafa/core/notifications/notification_scheduler.dart';
import 'package:thaqafa/core/notifications/notification_service.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/services/app_settings.dart';
import 'package:thaqafa/core/services/notifications_provider.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/thaqafa_mark.dart';

/// First-launch onboarding — three pages:
///   1. Concept: the project's promise + brand mark
///   2. Language: pick EN / FR / AR
///   3. Notifications: toggle the daily reminder + pick the hour
///
/// Each step is an editorial spread (frieze rosettes, mono colophon
/// eyebrow, serif headline) — same vocabulary as the rest of the
/// reading surface, so the transition into the app is seamless. A
/// "Skip" affordance in the corner lets the impatient user bail out
/// at any point; their current preferences (auto-detected locale,
/// notifications off) become their starting state.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final i18n = Translations.of(context);
    final notifsEnabled = ref.read(notificationsEnabledProvider);
    if (notifsEnabled) {
      // Onboarding is the natural place to ask — the user just opted
      // in by flipping the toggle, so the system sheet feels expected.
      await NotificationService.instance.requestPermissions();
      // Apply the schedule now (the toggle setter only fires when the
      // value *changes*, so a default-off → on flip is covered, but a
      // default-already-on case wouldn't otherwise reschedule).
      await ref.rescheduleDailyNotificationsFromPrefs(
        genericTitle: i18n.settings.notification_title,
        genericBody: i18n.settings.notification_body,
      );
    }
    await ref
        .read<OnboardingNotifier>(onboardingProvider.notifier)
        .complete();
    if (mounted) context.go(AppRoutes.today);
  }

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — skip affordance, right-aligned. Stays visible
            // on every step.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      i18n.onboarding.skip.toUpperCase(),
                      style: ThaqafaTypography.mono(
                        size: 11,
                        color: t.inkMute,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _ConceptPage(),
                  _LanguagePage(),
                  _NotificationsPage(),
                ],
              ),
            ),
            // Pagination + primary action.
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
              child: Column(
                children: [
                  _PaginationDots(active: _page, total: _pageCount),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: ValueKey('onboarding_primary_$_page'),
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.ink,
                        foregroundColor: t.paper,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        (_page == _pageCount - 1
                                ? i18n.onboarding.begin
                                : i18n.onboarding.kContinue)
                            .toUpperCase(),
                        style: ThaqafaTypography.mono(
                          size: 12,
                          color: t.paper,
                          letterSpacing: 1.6,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page 1 — the project's promise + brand mark. Identical content to
/// the previous single-step onboarding, just lifted into its own
/// widget so the PageView can animate between siblings.
class _ConceptPage extends StatelessWidget {
  const _ConceptPage();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        children: [
          Column(
            children: [
              const ThaqafaMark(size: 64),
              const SizedBox(height: 18),
              Text(
                i18n.onboarding.eyebrow.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.accent,
                  letterSpacing: 2.6,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FriezeRule(rosetteOnly: true, marginBottom: 28),
                  Text(
                    i18n.onboarding.headline,
                    textAlign: TextAlign.center,
                    style: ThaqafaTypography.serif(
                      size: 38,
                      color: t.ink,
                      weight: FontWeight.w500,
                      height: 1.05,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    i18n.onboarding.subhead,
                    textAlign: TextAlign.center,
                    style: ThaqafaTypography.serif(
                      size: 17,
                      color: t.inkSoft,
                      style: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const FriezeRule(rosetteOnly: true, marginTop: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 2 — pick a language. Tapping a tile commits immediately
/// through ``localeProvider`` so the rest of onboarding renders in the
/// chosen tongue, no "save" button needed.
class _LanguagePage extends ConsumerWidget {
  const _LanguagePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final current = ref.watch(localeProvider) ?? LocaleSettings.currentLocale;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            i18n.onboarding.lang_eyebrow.toUpperCase(),
            style: ThaqafaTypography.mono(
              size: 11,
              color: t.accent,
              letterSpacing: 2.6,
            ),
          ),
          const FriezeRule(rosetteOnly: true, marginTop: 18, marginBottom: 22),
          Text(
            i18n.onboarding.lang_headline,
            textAlign: TextAlign.center,
            style: ThaqafaTypography.serif(
              size: 30,
              color: t.ink,
              weight: FontWeight.w500,
              height: 1.1,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            i18n.onboarding.lang_subhead,
            textAlign: TextAlign.center,
            style: ThaqafaTypography.serif(
              size: 15,
              color: t.inkSoft,
              style: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          _LangTile(
            label: i18n.onboarding.lang_en,
            selected: current == AppLocale.en,
            onTap: () => ref.read(localeProvider.notifier).set(AppLocale.en),
          ),
          const SizedBox(height: 12),
          _LangTile(
            label: i18n.onboarding.lang_fr,
            selected: current == AppLocale.fr,
            onTap: () => ref.read(localeProvider.notifier).set(AppLocale.fr),
          ),
          const SizedBox(height: 12),
          _LangTile(
            label: i18n.onboarding.lang_ar,
            selected: current == AppLocale.ar,
            onTap: () => ref.read(localeProvider.notifier).set(AppLocale.ar),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? t.ink : t.rule,
            width: selected ? 1.4 : 0.6,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: ThaqafaTypography.serif(
                  size: 18,
                  color: t.ink,
                  weight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, color: t.ink, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Page 3 — notification toggle + time picker. Permission is requested
/// on **finish**, not on toggle, so the user can flip the switch
/// without immediately seeing an OS sheet.
class _NotificationsPage extends ConsumerWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final enabled = ref.watch(notificationsEnabledProvider);
    final time = ref.watch(notificationTimeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            i18n.onboarding.notif_eyebrow.toUpperCase(),
            style: ThaqafaTypography.mono(
              size: 11,
              color: t.accent,
              letterSpacing: 2.6,
            ),
          ),
          const FriezeRule(rosetteOnly: true, marginTop: 18, marginBottom: 22),
          Text(
            i18n.onboarding.notif_headline,
            textAlign: TextAlign.center,
            style: ThaqafaTypography.serif(
              size: 30,
              color: t.ink,
              weight: FontWeight.w500,
              height: 1.1,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            i18n.onboarding.notif_subhead,
            textAlign: TextAlign.center,
            style: ThaqafaTypography.serif(
              size: 15,
              color: t.inkSoft,
              style: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          _ToggleRow(
            label: i18n.onboarding.notif_enable,
            value: enabled,
            onChanged: (v) => ref
                .read(notificationsEnabledProvider.notifier)
                .set(
                  v,
                  title: i18n.settings.notification_title,
                  body: i18n.settings.notification_body,
                ),
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: enabled ? 1.0 : 0.4,
            child: IgnorePointer(
              ignoring: !enabled,
              child: _TimeRow(
                label: i18n.onboarding.notif_time,
                value: time,
                onChanged: (v) => ref
                    .read(notificationTimeProvider.notifier)
                    .set(
                      v,
                      title: i18n.settings.notification_title,
                      body: i18n.settings.notification_body,
                    ),
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        border: Border.all(color: t.rule, width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ThaqafaTypography.serif(
                size: 16,
                color: t.ink,
                weight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: t.ink,
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay value;
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
                    initialDateTime:
                        DateTime(2026, 1, 1, value.hour, value.minute),
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          border: Border.all(color: t.rule, width: 0.6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: ThaqafaTypography.serif(
                  size: 16,
                  color: t.ink,
                  weight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _format(value),
              style: ThaqafaTypography.mono(
                size: 18,
                color: t.ink,
                weight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationDots extends StatelessWidget {
  const _PaginationDots({required this.active, required this.total});

  final int active;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? t.ink : t.rule,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

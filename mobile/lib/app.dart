import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/core/router/app_router.dart';
import 'package:thaqafa/core/services/app_settings.dart';
import 'package:thaqafa/core/theme/app_theme.dart';
import 'package:thaqafa/i18n/strings.g.dart';

/// Root MaterialApp.router — wires GoRouter, Slang locale delegates,
/// and the light/dark theme builders.
class ThaqafaApp extends ConsumerWidget {
  const ThaqafaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => Translations.of(ctx).app.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => _ReadingScaleHost(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Owns the live reading-scale state and converts a two-finger pinch
/// anywhere in the app into a text-scale update.
///
/// Why a wrapper widget instead of just ``MediaQuery`` inline in
/// ``ThaqafaApp.build``: we want the *live* scale to be cheap to
/// re-render (no prefs hit on every pinch frame) and to *snap* to a
/// preset on pinch-end so the Settings segmented row stays in sync
/// with what the user picked freehand.
///
/// Gesture-arena interaction: ``GestureDetector.onScale*`` activates a
/// ``ScaleGestureRecognizer`` that only wins arena bids when two or
/// more pointers are down. Single-finger scrolls inside ``ListView``
/// still resolve to the inner ``Scrollable`` — pinch and scroll coexist.
class _ReadingScaleHost extends ConsumerStatefulWidget {
  const _ReadingScaleHost({required this.child});

  final Widget child;

  @override
  ConsumerState<_ReadingScaleHost> createState() => _ReadingScaleHostState();
}

class _ReadingScaleHostState extends ConsumerState<_ReadingScaleHost> {
  /// Live value during an active pinch. ``null`` between gestures —
  /// in that case we read straight from the persisted provider value.
  double? _liveScale;
  double _pinchBaseline = 1.0;

  // Match the segmented row in Settings → Reading size. Pinching past
  // the extremes is clamped; on pinch-end we snap to the nearest of
  // these so the Settings highlight stays meaningful.
  static const _presets = <double>[0.85, 1.0, 1.15, 1.3];
  static const _minScale = 0.75;
  static const _maxScale = 1.55;

  double _snap(double v) =>
      _presets.reduce((a, b) => (v - a).abs() < (v - b).abs() ? a : b);

  @override
  Widget build(BuildContext context) {
    final stored = ref.watch(readingScaleProvider);
    final effective = _liveScale ?? stored;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (details) {
        if (details.pointerCount < 2) return;
        _pinchBaseline = effective;
      },
      onScaleUpdate: (details) {
        if (details.pointerCount < 2) return;
        final next = (_pinchBaseline * details.scale).clamp(_minScale, _maxScale);
        if (next != _liveScale) setState(() => _liveScale = next);
      },
      onScaleEnd: (_) {
        if (_liveScale == null) return;
        final snapped = _snap(_liveScale!);
        // Fire-and-forget — provider.set() writes to prefs async, we
        // clear the live override right away so the next render reads
        // the persisted value.
        ref.read(readingScaleProvider.notifier).set(snapped);
        setState(() => _liveScale = null);
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(effective),
        ),
        child: widget.child,
      ),
    );
  }
}

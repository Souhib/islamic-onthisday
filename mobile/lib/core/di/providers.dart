import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/storage/preferences_service.dart';

/// Single-source-of-truth provider for `PreferencesService`. The
/// instance is constructed in `bootstrap.dart` and the
/// `prefsServiceProvider` is overridden at app boot — never read
/// directly without that override.
final prefsServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(
    'prefsServiceProvider must be overridden at app boot',
  );
});

/// Reactive flag for the onboarding gate. Reads the prefs once and
/// notifies listeners when `setHasCompletedOnboarding` is called via
/// `OnboardingNotifier.complete()`.
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsServiceProvider).hasCompletedOnboarding;

  Future<void> complete() async {
    await ref.read(prefsServiceProvider).setHasCompletedOnboarding(true);
    state = true;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

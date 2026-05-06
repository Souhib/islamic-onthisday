import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotd_mobile/core/di/providers.dart';
import 'package:iotd_mobile/features/onboarding/onboarding_screen.dart';
import 'package:iotd_mobile/features/today/today_screen.dart';

/// Top-level router. Reads `onboardingProvider` for the redirect gate:
///   - hasCompletedOnboarding == false  → /onboarding
///   - hasCompletedOnboarding == true   → /today
///
/// Keep route names + paths centralised here so we have a single map of
/// the app's navigation surface.
class AppRoutes {
  AppRoutes._();
  static const onboarding = '/onboarding';
  static const today = '/today';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    redirect: (context, state) {
      final completed = ref.read<bool>(onboardingProvider);
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!completed && !atOnboarding) return AppRoutes.onboarding;
      if (completed && atOnboarding) return AppRoutes.today;
      return null;
    },
    refreshListenable: _RouterRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.today,
        builder: (context, state) => const TodayScreen(),
      ),
    ],
  );
});

/// Bridges the Riverpod `onboardingProvider` to GoRouter's
/// `refreshListenable` so the redirect re-evaluates when the
/// onboarding flag flips.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen<bool>(onboardingProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

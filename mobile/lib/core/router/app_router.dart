import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iotd_mobile/core/di/providers.dart';
import 'package:iotd_mobile/features/about/about_screen.dart';
import 'package:iotd_mobile/features/auth/sign_in_screen.dart';
import 'package:iotd_mobile/features/auth/sign_up_screen.dart';
import 'package:iotd_mobile/features/event/event_detail_screen.dart';
import 'package:iotd_mobile/features/lesson/lesson_detail_screen.dart';
import 'package:iotd_mobile/features/observance/observance_detail_screen.dart';
import 'package:iotd_mobile/features/observance/observances_list_screen.dart';
import 'package:iotd_mobile/features/onboarding/onboarding_screen.dart';
import 'package:iotd_mobile/features/person/person_detail_screen.dart';
import 'package:iotd_mobile/features/recent/recent_screen.dart';
import 'package:iotd_mobile/features/settings/settings_screen.dart';
import 'package:iotd_mobile/features/shared/app_shell.dart';
import 'package:iotd_mobile/features/today/today_screen.dart';

/// Top-level router. Reads `onboardingProvider` for the redirect gate:
///   - hasCompletedOnboarding == false  → /onboarding
///   - hasCompletedOnboarding == true   → /today (inside the shell)
///
/// Detail routes (`/event/:slug`, `/lesson/:slug`) are pushed on top of
/// the shell so the bottom nav disappears while reading.
class AppRoutes {
  AppRoutes._();
  static const onboarding = '/onboarding';
  static const today = '/today';
  static const recent = '/recent';
  static const settings = '/settings';
  static const event = '/event';
  static const lesson = '/lesson';
  static const person = '/person';
  static const observance = '/observance';
  static const observances = '/observances';
  static const about = '/about';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
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
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.today,
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: AppRoutes.recent,
            builder: (context, state) => const RecentScreen(),
          ),
          GoRoute(
            path: AppRoutes.observances,
            builder: (context, state) => const ObservancesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.event}/:slug',
        builder: (context, state) =>
            EventDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '${AppRoutes.lesson}/:slug',
        builder: (context, state) =>
            LessonDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '${AppRoutes.person}/:slug',
        builder: (context, state) =>
            PersonDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '${AppRoutes.observance}/:slug',
        builder: (context, state) =>
            ObservanceDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen<bool>(onboardingProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

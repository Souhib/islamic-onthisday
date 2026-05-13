import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thaqafa/core/analytics/analytics.dart';
import 'package:thaqafa/core/di/providers.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/features/about/about_screen.dart';
import 'package:thaqafa/features/auth/sign_in_screen.dart';
import 'package:thaqafa/features/auth/sign_up_screen.dart';
import 'package:thaqafa/features/bookmarks/bookmarks_list_screen.dart';
import 'package:thaqafa/features/event/event_detail_screen.dart';
import 'package:thaqafa/features/lesson/lesson_detail_screen.dart';
import 'package:thaqafa/features/observance/observance_detail_screen.dart';
import 'package:thaqafa/features/observance/observances_list_screen.dart';
import 'package:thaqafa/features/onboarding/onboarding_screen.dart';
import 'package:thaqafa/features/person/person_detail_screen.dart';
import 'package:thaqafa/features/recent/recent_screen.dart';
import 'package:thaqafa/features/settings/settings_screen.dart';
import 'package:thaqafa/features/shared/app_shell.dart';
import 'package:thaqafa/features/today/today_screen.dart';

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
  static const bookmarks = '/bookmarks';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
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
            pageBuilder: (context, state) => _instantPage(state, const TodayScreen()),
          ),
          GoRoute(
            path: AppRoutes.recent,
            pageBuilder: (context, state) => _instantPage(state, const RecentScreen()),
          ),
          GoRoute(
            path: AppRoutes.observances,
            pageBuilder: (context, state) =>
                _instantPage(state, const ObservancesListScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                _instantPage(state, const SettingsScreen()),
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
        path: AppRoutes.bookmarks,
        builder: (context, state) => const BookmarksListScreen(),
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

  // Fire a page-view on every navigation — push, pop, replace, shell
  // tab swap, deep link, all of them. ``routerDelegate.notifyListeners``
  // runs after the configuration update, so ``currentConfiguration``
  // is the *new* location by the time we read it.
  router.routerDelegate.addListener(() {
    final uri = router.routerDelegate.currentConfiguration.uri;
    Analytics.instance.trackPageView(
      uri.path,
      language: LocaleSettings.currentLocale.languageCode,
    );
  });

  return router;
});

/// Bottom-nav routes use an instant page — no slide, no fade. Tabs are
/// peers (no hierarchical order) so any directional animation would
/// misrepresent the relationship between them; this also matches iOS
/// HIG (Tab Bar) and Material's NavigationBar behaviour.
///
/// Detail routes (``/event/:slug`` etc.) are pushed and inherit the
/// default Material/Cupertino transition, which is what users expect
/// for a navigation push.
CustomTransitionPage<void> _instantPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, _, _, child) => child,
    child: child,
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen<bool>(onboardingProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/state/auth/auth_providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/profile/presentation/profile/profile_page.dart';
import '../features/profile/presentation/favorites_page.dart';
import '../features/profile/presentation/history_page.dart';
import '../features/profile/presentation/preferences_page.dart';
import '../features/profile/user_events_page.dart';
import '../features/settings/presentation/settings/settings_page.dart';
import 'app.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    redirect: (context, state) {
      final loggedIn = authState.asData?.value != null;
      final loggingIn = state.matchedLocation == '/login';
      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const App()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
          path: '/settings', builder: (context, state) => const SettingsPage()),
      GoRoute(
          path: '/preferences',
          builder: (context, state) => const PreferencesPage()),
      GoRoute(
          path: '/user_event',
          builder: (context, state) => const UserEventsPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/history', builder: (context, state) => const HistoryPage()),
      GoRoute(
          path: '/favorites', builder: (context, state) => const FavoritesPage()),
    ],
  );
});

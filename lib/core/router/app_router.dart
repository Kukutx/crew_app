import 'dart:async';

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/events_detail_page.dart';
import 'package:crew_app/features/events/presentation/user_events_page.dart';
import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:crew_app/features/events/presentation/events_list_page.dart';
import 'package:crew_app/features/events/presentation/map/events_map_page.dart';
import 'package:crew_app/features/events/presentation/search_events_page.dart';
import 'package:crew_app/features/profile/presentation/profile_page.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/profile/presentation/preferences_page.dart';
import 'package:crew_app/features/profile/presentation/favorites_page.dart';
import 'package:crew_app/features/profile/presentation/history_page.dart';
import 'package:crew_app/features/settings/presentation/settings_page.dart';
import 'package:crew_app/app/app_shell.dart';
import 'package:crew_app/core/state/app_provider/app_providers.dart';

// // 暴露一个 Provider，MaterialApp.router 直接消费
// final routerProvider = Provider<GoRouter>((ref) {
//   // 监听登录状态，触发重定向与刷新
//   final authAsync = ref.watch(authStateProvider);

//   return GoRouter(
//     initialLocation: '/map',
//     debugLogDiagnostics: false,
//     refreshListenable: GoRouterRefreshStream(
//       FirebaseAuth.instance.authStateChanges(),
//     ),
//     redirect: (context, state) {
//       final isLoggedIn = authAsync.asData?.value != null;
//       final loggingIn = state.matchedLocation == '/login';

//       if (!isLoggedIn) {
//         // 未登录：仅允许停留在 /login
//         return loggingIn ? null : '/login';
//       }
//       // 已登录：避免停留在登录页
//       if (isLoggedIn && loggingIn) return '/map';
//       return null;
//     },
//     routes: [
//       GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

//       // 底部导航 Shell（保持页面状态用 IndexedStack）
//       ShellRoute(
//         builder: (context, state, child) => AppShell(child: child),
//         routes: [
//           GoRoute(path: '/events', name: 'events', builder: (_, __) => const EventsListPage()),
//           GoRoute(path: '/map',    name: 'map',    builder: (_, __) => const EventsMapPage()),
//           GoRoute(path: '/search', name: 'search', builder: (_, __) => const SearchEventsPage()),
//           GoRoute(path: '/profile',name: 'profile',builder: (_, __) => const ProfilePage()),
//         ],
//       ),

//       // 其他页面（非底部导航）
//       GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
//       GoRoute(path: '/about',    builder: (_, __) => const AboutPage()),
//       GoRoute(path: '/preferences', builder: (_, __) => const PreferencesPage()),
//       GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
//       GoRoute(path: '/favorites', builder: (_, __) => const FavoritesPage()),
//     ],
//   );
// });

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/map',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final isLoggedIn = authAsync.asData?.value != null;
      final loggingIn = state.matchedLocation == '/login';
      if (!isLoggedIn) return loggingIn ? null : '/login';
      if (isLoggedIn && loggingIn) return '/map';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

      // ✅ StatefulShellRoute：每个分支一个独立 Navigator 栈，状态与历史都会保留
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                name: 'events',
                builder: (_, __) => const EventsListPage(),
                // 这里可以继续加子路由，例如: /events/:id
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                builder: (_, __) => const EventsMapPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (_, __) => const SearchEventsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // 其他页面（非底部导航）
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
      GoRoute(
          path: '/preferences', builder: (_, __) => const PreferencesPage()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
      GoRoute(path: '/favorites', builder: (_, __) => const FavoritesPage()),
      GoRoute(path: '/user_events', builder: (_, __) => const UserEventsPage()),
      GoRoute(
        path: '/event/detail',
        name: 'eventDetail',
        builder: (context, state) {
          final event = state.extra as Event;
          return EventDetailPage(event: event);
        },
      ),
    ],
  );
});

// 小工具：用 Stream 作为 Listenable，go_router 官方文档提供的模式
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

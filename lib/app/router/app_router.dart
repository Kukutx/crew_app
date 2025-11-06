import 'package:crew_app/app/app.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/expenses/expenses_page.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/features/user/presentation/pages/edit_profile/edit_profile_page.dart';
import 'package:crew_app/features/events/presentation/pages/drafts/my_drafts_page.dart';
import 'package:crew_app/features/user/presentation/pages/friends/add_friend_page.dart';
import 'package:crew_app/features/events/presentation/pages/moment/my_moments_page.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/wallet_page.dart';
import 'package:crew_app/features/settings/presentation/settings_page.dart';
import 'package:crew_app/features/settings/presentation/pages/support/support_feedback_page.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/shared/widgets/qr_scanner/qr_scanner_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRoutePaths {
  static const String home = '/';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String editProfile = '/edit_profile';
  static const String messagesChat = '/messages_chat';
  static const String expenses = '/expenses';
  static const String wallet = '/wallet';
  static const String support = '/support';
  static const String moments = '/moments';
  static const String drafts = '/drafts';
  static const String addFriend = '/add_friend';
  static const String qrScanner = '/qr-scanner';
  static const String myQrCode = '/my-qr-code';
  static const String profile = '/profile';
}

class AppRouteNames {
  static const String home = 'home';
  static const String login = 'login';
  static const String settings = 'settings';
  static const String editProfile = 'edit_profile';
  static const String messagesChat = 'messages_chat';
  static const String expenses = 'expenses';
  static const String wallet = 'wallet';
  static const String support = 'support';
  static const String moments = 'moments';
  static const String drafts = 'drafts';
  static const String addFriend = 'add_friend';
  static const String qrScanner = 'qr_scanner';
  static const String myQrCode = 'my_qr_code';
  static const String profile = 'profile';
}

final crewAppRouterProvider = Provider<GoRouter>((ref) {
  final observer = ref.watch(talkerRouteObserverProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppRoutePaths.home,
    observers: [observer],
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isLoginPage = state.matchedLocation == AppRoutePaths.login;

      // 如果未登录且不在登录页，重定向到登录页
      if (!isLoggedIn && !isLoginPage) {
        return AppRoutePaths.login;
      }

      // 如果已登录且在登录页，重定向到首页
      if (isLoggedIn && isLoginPage) {
        return AppRoutePaths.home;
      }

      // 其他情况不重定向
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.home,
        name: AppRouteNames.home,
        builder: (context, state) => const App(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutePaths.editProfile,
        name: AppRouteNames.editProfile,
        builder: (context, state) => EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutePaths.messagesChat,
        name: AppRouteNames.messagesChat,
        builder: (context, state) => const ChatSheet(),
      ),
      GoRoute(
        path: AppRoutePaths.expenses,
        name: AppRouteNames.expenses,
        builder: (context, state) => const ExpensesPage(),
      ),
      GoRoute(
        path: AppRoutePaths.wallet,
        name: AppRouteNames.wallet,
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: AppRoutePaths.support,
        name: AppRouteNames.support,
        builder: (context, state) => const SupportFeedbackPage(),
      ),
      GoRoute(
        path: AppRoutePaths.moments,
        name: AppRouteNames.moments,
        builder: (context, state) => const MyMomentsPage(),
      ),
      GoRoute(
        path: AppRoutePaths.drafts,
        name: AppRouteNames.drafts,
        builder: (context, state) => const MyDraftsPage(),
      ),
      GoRoute(
        path: AppRoutePaths.addFriend,
        name: AppRouteNames.addFriend,
        builder: (context, state) => const AddFriendPage(),
      ),
      GoRoute(
        path: AppRoutePaths.qrScanner,
        name: AppRouteNames.qrScanner,
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.profile,
        name: AppRouteNames.profile,
        builder: (context, state) {
          final uid = state.extra is String ? state.extra as String : null;
          return UserProfilePage(uid: uid);
        },
      ),
    ],
  );
});


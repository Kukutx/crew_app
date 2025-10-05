import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';

/// 登录完成后跳转的路由名
const String kHomeRoute = '/';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final providers = <fui.AuthProvider>[
      // 1) 邮箱密码
      fui.EmailAuthProvider(),
      // 2) Phone（如需）
      // fui.PhoneAuthProvider(), // ← 使用 firebase_ui_auth 的 PhoneAuthProvider
      // 3) Google（clientId 请替换成你自己的）
      GoogleProvider(
          clientId:
              '417490407531-111poe29m187rdr8d43mp93v9fq92of1.apps.googleusercontent.com'),
      // 4) Apple（iOS 必须提供 Sign in with Apple，如果你启用了其他第三方登录）
      if (Theme.of(context).platform == TargetPlatform.iOS) AppleProvider(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.login_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // 标题居中
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // 关闭页面
          },
        ),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth.clamp(360.0, 480.0);
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF9013FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: fui.SignInScreen(
                          providers: providers,
                          showAuthActionSwitch: false,
                          headerBuilder: (context, constraints, _) => Column(
                            children: [
                              const SizedBox(height: 8),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4A90E2), Color(0xFF7B61FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Icon(
                                    Icons.nightlight_round,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loc.login_title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loc.login_subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                          subtitleBuilder: (context, action) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              action == fui.AuthAction.signIn
                                  ? loc.login_subtitle
                                  : loc.login_footer,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          footerBuilder: (context, action) => Column(
                            children: [
                              const Divider(height: 32),
                              Text(
                                loc.login_footer,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          actions: [
            fui.AuthStateChangeAction<fui.SignedIn>((context, state) async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(authServiceProvider)
                  .getIdToken(forceRefresh: true);

              final profile = await ref
                  .read(authenticatedUserProvider.notifier)
                  .refreshProfile();

              if (profile != null) {
                debugPrint('Authenticated user: ${profile.email}');
              } else {
                debugPrint('Authenticated user profile not available.');
              }
            } on ApiException catch (error) {
              messenger.showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            } catch (error, stackTrace) {
              debugPrint('Failed to sync user: $error\n$stackTrace');
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Failed to sync user information.'),
                ),
              );
            }

            Navigator.of(context).pushReplacementNamed(kHomeRoute);
          }),
          fui.AuthStateChangeAction<fui.UserCreated>((context, state) {
            Navigator.of(context).pushReplacementNamed(kHomeRoute);
          }),
          fui.AuthStateChangeAction<fui.CredentialLinked>((context, state) {
            Navigator.of(context).pushReplacementNamed(kHomeRoute);
          }),
        ],
                          sideBuilder: (context, constraints) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  loc.login_side_info,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.login_footer,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

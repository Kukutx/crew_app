import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
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
      appBar: AppBar(
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
      body: fui.SignInScreen(
        providers: providers,
        headerBuilder: (context, constraints, _) => Column(
          children: const [
            SizedBox(height: 32),
            Icon(
              Icons.nightlight_round, // 这里可以换成你自己的 logo 图片
              size: 80,
              color: Colors.blueAccent,
            ),
            SizedBox(height: 16),
          ],
        ),
        subtitleBuilder: (context, action) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(loc.login_subtitle),
        ),
        footerBuilder: (context, action) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(loc.login_footer),
        ),
        actions: [
          fui.AuthStateChangeAction<fui.SignedIn>((context, state) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await ref
                  .read(authServiceProvider)
                  .getIdToken(forceRefresh: true);

              final profile = await ref
                  .read(apiServiceProvider)
                  .getAuthenticatedUserDetail();

              debugPrint('Authenticated user: ${profile.email}');
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
          child: Text(
            loc.login_side_info,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

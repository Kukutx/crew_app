import 'package:flutter/material.dart';

// 用前缀避免与 UI 包里的 Provider 名称冲突
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:go_router/go_router.dart';

/// 登录完成后跳转的路由名
const String kHomeRoute = '/';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = <fui.AuthProvider>[
      // 1) 邮箱密码
      fui.EmailAuthProvider(),
      // 2) Phone（如需）
      fui.PhoneAuthProvider(), // ← 使用 firebase_ui_auth 的 PhoneAuthProvider
      // 3) Google（clientId 请替换成你自己的）
      GoogleProvider(
          clientId:
              '417490407531-fq20k42jlls80ognl9sotjecdg3tbmhr.apps.googleusercontent.com'),
      // 4) Apple（iOS 必须提供 Sign in with Apple，如果你启用了其他第三方登录）
      if (Theme.of(context).platform == TargetPlatform.iOS) AppleProvider(),
    ];

    // return Scaffold(
    //   body: Center(
    //     child: ConstrainedBox(
    //       constraints: const BoxConstraints(maxWidth: 560),
    //       child: Card(
    //         margin: const EdgeInsets.all(24),
    //         elevation: 2,
    //         clipBehavior: Clip.antiAlias,
    //         child: fui.SignInScreen(
    //           providers: providers,
    //           headerBuilder: (context, _, __) => const Padding(
    //             padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
    //             child: Text('欢迎来到 Crew', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
    //           ),
    //           subtitleBuilder: (context, action) => const Padding(
    //             padding: EdgeInsets.symmetric(horizontal: 24),
    //             child: Text('基于地理位置组织活动 · 一键加入你的 Crew'),
    //           ),
    //           footerBuilder: (context, action) => const Padding(
    //             padding: EdgeInsets.all(16),
    //             child: Text('继续即表示同意《服务条款》和《隐私政策》'),
    //           ),
    //           actions: [
    //             fui.AuthStateChangeAction<fui.SignedIn>((context, state) async {
    //               await fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
    //               if (context.mounted) context.go(kHomeRoute);
    //             }),
    //             fui.AuthStateChangeAction<fui.UserCreated>((context, state) {
    //               context.go(kHomeRoute);
    //             }),
    //             fui.AuthStateChangeAction<fui.CredentialLinked>((context, state) {
    //               context.go(kHomeRoute);
    //             }),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    return fui.SignInScreen(
      providers: providers,
      headerBuilder: (context, constraints, _) => const Padding(
        padding: EdgeInsets.only(top: 40, bottom: 16),
        child: Text(
          '欢迎来到 Crew',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      subtitleBuilder: (context, action) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('基于地理位置组织活动，一键加入你的 Crew'),
      ),
      footerBuilder: (context, action) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text('继续即表示同意我们的服务条款与隐私政策'),
      ),
      // 登录/注册状态回调：成功后跳转
      actions: [
        fui.AuthStateChangeAction<fui.SignedIn>((context, state) {
          // 刷新 ID Token（拿到最新的 Custom Claims，例如订阅标记）
          fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
          context.go(kHomeRoute);
        }),
        fui.AuthStateChangeAction<fui.UserCreated>((context, state) {
          context.go(kHomeRoute);
        }),
        fui.AuthStateChangeAction<fui.CredentialLinked>((context, state) {
          context.go(kHomeRoute);
        }),
      ],
      // // 主题美化（可选）
      // styles: const {
      //   fui.EmailAuthProvider: AuthProviderButtonStyle(height: 48),
      // },
      sideBuilder: (context, constraints) => const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '发现周边活动 · 快速组局 · 订阅解锁高级玩法',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

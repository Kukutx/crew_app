import 'package:flutter/material.dart';

// 用前缀避免与 UI 包里的 Provider 名称冲突
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';

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
    title: const Text(
      '欢迎来到 Crew',
      style: TextStyle(fontWeight: FontWeight.bold),
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
    subtitleBuilder: (context, action) => const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text('基于地理位置组织活动，一键加入你的 Crew'),
    ),
    footerBuilder: (context, action) => const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text('继续即表示同意我们的服务条款与隐私政策'),
    ),
    actions: [
      fui.AuthStateChangeAction<fui.SignedIn>((context, state) {
        fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
        Navigator.of(context).pushReplacementNamed(kHomeRoute);
      }),
      fui.AuthStateChangeAction<fui.UserCreated>((context, state) {
        Navigator.of(context).pushReplacementNamed(kHomeRoute);
      }),
      fui.AuthStateChangeAction<fui.CredentialLinked>((context, state) {
        Navigator.of(context).pushReplacementNamed(kHomeRoute);
      }),
    ],
    sideBuilder: (context, constraints) => const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        '发现周边活动 · 快速组局 · 订阅解锁高级玩法',
        style: TextStyle(fontSize: 16),
      ),
    ),
  ),
);
  }
}

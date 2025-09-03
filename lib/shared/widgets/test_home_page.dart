import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await fa.FirebaseAuth.instance.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已退出登录')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fa.User?>(
      stream: fa.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // 没有登录 → 跳到登录页
        if (user == null) {
          return const LoginPage();
        }

        // 已登录 → 显示登出按钮
        return Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text('Sign out'),
            ),
          ),
        );
      },
    );
  }
}

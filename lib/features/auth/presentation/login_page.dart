import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/privacy/privacy_documents_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

/// 登录完成后跳转的路由名
const String kHomeRoute = '/';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  bool _agreed = false;
  bool _loading = false;

  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  // 一个“抖动”曲线：左右快速小幅位移
  late final Animation<double> _shakeAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOutCubic));

  void _triggerShake() {
    if (_shakeCtrl.isAnimating) return;
    _shakeCtrl.forward(from: 0);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text("Please agree to the terms before continuing."),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (!_agreed) {
      _triggerShake();
      return;
    }
    if (_loading) return;

    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        // 如果需要：provider.setCustomParameters({'prompt': 'select_account'});
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn(
          // iOS 可指定 clientId（可选）；Android 一般不需要
          clientId: Platform.isIOS
              ? '417490407531-111poe29m187rdr8d43mp93v9fq92of1.apps.googleusercontent.com'
              : null,
        );
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _loading = false);
          return; // 用户取消
        }
        final googleAuth = await googleUser.authentication;
        final oauth = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await FirebaseAuth.instance.signInWithCredential(oauth);
      }

      // 同步你现有后端用户信息
      await ref.read(authServiceProvider).getIdToken(forceRefresh: true);
      await ref.read(authenticatedUserProvider.notifier).refreshProfile();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(kHomeRoute);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, st) {
      debugPrint('Google sign-in failed: $e\n$st');
      messenger.showSnackBar(
        SnackBar(content: Text("Login failed. Please try again later.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openPrivacy() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyDocumentsPage()));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // —— 小红书风格要点 —— 
    // 1) 顶部大 Logo / 品牌字样，留白充足
    // 2) 居中一个主按钮（Google 登录），圆角胶囊、轻描边
    // 3) 底部协议区：未勾选时按钮抖动并提示；勾选后按钮变为主态

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 顶部品牌
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 可换为你的 App 图标
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.nightlight_round, color: cs.primary, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.login_title, // 例如：欢迎来到 Crew
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        loc.login_subtitle, // 一句简短 slogan/价值主张
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 中央登录按钮
            Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: SizedBox(
                  width: 320,
                  height: 56,
                  child: _GoogleLikeButton(
                    enabled: _agreed && !_loading,
                    loading: _loading,
                    onTap: _signInWithGoogle,
                  ),
                ),
              ),
            ),

            // 底部协议区 + 辅助文案（带抖动）
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreed,
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(loc.login_agreement_prefix, style: theme.textTheme.bodySmall),
                                GestureDetector(
                                  onTap: _openPrivacy,
                                  child: Text(
                                    loc.login_agreement_terms,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text('、', style: theme.textTheme.bodySmall),
                                GestureDetector(
                                  onTap: _openPrivacy,
                                  child: Text(
                                    loc.login_agreement_privacy,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text('、', style: theme.textTheme.bodySmall),
                                GestureDetector(
                                  onTap: _openPrivacy,
                                  child: Text(
                                    loc.login_agreement_children,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.login_footer,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 仿小红书的主按钮：灰白底、描边、圆角胶囊；未启用时降低不透明度，点击触发 onTap（外部决定是否抖动）
class _GoogleLikeButton extends StatelessWidget {
  const _GoogleLikeButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: enabled && !loading ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: enabled ? cs.outlineVariant : cs.outlineVariant.withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 建议放置你的 Google “G” 图标资源（24x24）
                    // Image.asset('assets/icons/google_g.png', width: 20, height: 20),
                    Icon(Icons.login, size: 20), // 占位；换为你的图标
                    const SizedBox(width: 10),
                    Text(
                      // 文案尽量简短
                      'Continue with Google',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

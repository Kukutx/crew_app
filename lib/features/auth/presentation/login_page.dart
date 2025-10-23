import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  Future<void> _signInWithGoogle() async {
    // 这里不再做“是否勾选”的校验，交给按钮自身处理动画与提示
    if (_loading) return;

    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn(
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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                      loc.login_title,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        loc.login_subtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 中央登录按钮（自身完成“未勾选时轻摇+SnackBar”）
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 320,
                height: 56,
                child: GoogleWobbleButton(
                  loading: _loading,
                  canProceed: _agreed, // 是否允许继续；未勾选时按钮自己抖动并提示
                  invalidMessage: "Please agree to the terms before continuing.",
                  label: 'Continue with Google',
                  svgAssetPath: 'assets/images/icons/google_g.svg',
                  onProceed: _signInWithGoogle,
                ),
              ),
            ),

            // 底部协议区
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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

/// 带“轻摇”验证动画的 Google 按钮：
/// - 未满足 canProceed 时：左右轻摇 + SnackBar 提示；
/// - 使用 flutter_svg 显示 Google “G” 图标；
/// - 外观遵循“浅底、描边、圆角胶囊”风格；
class GoogleWobbleButton extends StatefulWidget {
  const GoogleWobbleButton({
    super.key,
    required this.loading,
    required this.canProceed,
    required this.onProceed,
    required this.label,
    required this.svgAssetPath,
    this.invalidMessage,
  });

  final bool loading;
  final bool canProceed;
  final VoidCallback onProceed;
  final String label;
  final String svgAssetPath;
  final String? invalidMessage;

  @override
  State<GoogleWobbleButton> createState() => _GoogleWobbleButtonState();
}

class _GoogleWobbleButtonState extends State<GoogleWobbleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _shakeAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOutCubic));

  void _triggerInvalidFeedback() {
    if (!_shakeCtrl.isAnimating) {
      _shakeCtrl.forward(from: 0);
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(widget.invalidMessage ?? 'Please complete the required steps.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 视觉“启用/未启用”反馈；注意依然允许点击以触发验证动画
    final bool enabledVisual = widget.canProceed && !widget.loading;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnim.value, 0),
          child: child,
        );
      },
      child: Opacity(
        opacity: enabledVisual ? 1 : 0.65,
        child: InkWell(
          onTap: widget.loading
              ? null
              : () {
                  if (!widget.canProceed) {
                    _triggerInvalidFeedback();
                    return;
                  }
                  widget.onProceed();
                },
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(4),
  border: Border.all(color: const Color(0xFFDADCE0)),
),
child: Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 12),
      SvgPicture.asset(widget.svgAssetPath, width: 18, height: 18),
      const SizedBox(width: 12),
      Text(
        widget.label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF3C4043),
        ),
      ),
      const SizedBox(width: 12),
    ],
  ),
),
          ),
        ),
      ),
    );
  }
}

import 'dart:io' show Platform;
import 'package:crew_app/app/router/app_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/settings/presentation/pages/privacy/privacy_documents_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _agreed = false;
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    // 这里不再做"是否勾选"的校验，交给按钮自身处理动画与提示
    if (_loading) return;

    setState(() => _loading = true);

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
          if (mounted) setState(() => _loading = false);
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
      context.go(AppRoutePaths.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e, st) {
      debugPrint('Google sign-in failed: $e\n$st');
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      if (loc != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.login_failed_message)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openPrivacy() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PrivacyDocumentsPage()));
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
                        color: cs.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/icons/logo_login.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain, // 保持比例不裁剪
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.login_title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        loc.login_subtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
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
                child: GoogleNeoButton(
                  loading: _loading,
                  canProceed: _agreed,
                  label: 'Continue with Google',
                  svgAssetPath: 'assets/images/icons/google_g.svg',
                  iconColor: Colors.white, // 纯白
                  radius: 18, // 圆角 18
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
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                loc.login_agreement_prefix,
                                style: theme.textTheme.bodySmall,
                              ),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
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

class GoogleNeoButton extends StatefulWidget {
  const GoogleNeoButton({
    super.key,
    required this.loading,
    required this.canProceed,
    required this.onProceed,
    required this.label,
    required this.svgAssetPath,
    this.invalidMessage,
    this.radius = 18, // 新：圆角
    this.iconColor = Colors.white, // 新：图标纯色（白）
  });

  final bool loading;
  final bool canProceed;
  final VoidCallback onProceed;
  final String label;
  final String svgAssetPath;
  final String? invalidMessage;
  final double radius;
  final Color iconColor;

  @override
  State<GoogleNeoButton> createState() => _GoogleNeoButtonState();
}

class _GoogleNeoButtonState extends State<GoogleNeoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final enabled = widget.canProceed && !widget.loading;

    // 比 surface 略亮，形成凸起
    final base = Color.alphaBlend(
      cs.onSurface.withValues(alpha: 0.06),
      cs.surface,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 56,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(widget.radius), // 圆角 18
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: _pressed || widget.loading
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      offset: const Offset(2, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.04),
                      offset: const Offset(-2, -3),
                      blurRadius: 6,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      offset: const Offset(6, 8),
                      blurRadius: 18,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.06),
                      offset: const Offset(-6, -8),
                      blurRadius: 18,
                    ),
                  ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pressed || widget.loading
                  ? [base, base]
                  : [
                      Color.alphaBlend(
                        Colors.white.withValues(alpha: 0.04),
                        base,
                      ),
                      Color.alphaBlend(
                        Colors.black.withValues(alpha: 0.06),
                        base,
                      ),
                    ],
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.radius),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              onTap: enabled ? widget.onProceed : null,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: widget.loading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          key: const ValueKey('content'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 直接用纯白 SVG 图标（无方块）
                            SvgPicture.asset(
                              widget.svgAssetPath,
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                // 强制单色
                                widget.iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withValues(alpha: 0.92),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 使用 flutter_svg 显示 Google “G” 图标的登录按钮。
///
/// - 当 [canProceed] 为 `false` 或 [loading] 为 `true` 时按钮呈禁用态并阻止点击；
/// - 外观遵循“浅底、描边、圆角胶囊”风格；
class GoogleWobbleButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 视觉“启用/未启用”反馈；
    final bool enabledVisual = canProceed && !loading;

    return Opacity(
      opacity: enabledVisual ? 1 : 0.65,
      child: Material(
        color: theme.colorScheme.surface,
        shape: const StadiumBorder(side: BorderSide(color: Color(0xFFDADCE0))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: (!canProceed || loading) ? null : onProceed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(svgAssetPath, width: 18, height: 18),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3C4043),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

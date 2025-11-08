import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/core/config/app_theme.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MyQrCodeScreen extends ConsumerWidget {
  const MyQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);

    // 如果用户未登录，显示提示信息
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.qr_scanner_my_code),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.login_prompt,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push(AppRoutePaths.login),
                  child: const Text('登录'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 生成二维码数据（使用用户ID）
    final qrData = 'crewapp://user/${currentUser.uid}';
    final baseColor = colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.qr_scanner_my_code),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // 二维码卡片
              Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  gradient: AppTheme.neumorphicGradient(baseColor, isDark: isDark),
                  boxShadow: AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
                ),
                child: Column(
                  children: [
                    // 二维码
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 240.0,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 用户信息
                    Text(
                      currentUser.displayName ?? currentUser.email ?? currentUser.uid,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentUser.email != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        currentUser.email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 提示文字
              Text(
                '扫描二维码可添加我为好友',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareQrCode(context, qrData, loc),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('分享'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _saveQrCode(context, loc),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('保存'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareQrCode(BuildContext context, String qrData, AppLocalizations loc) {
    Share.share(
      '我的 Crew 账号二维码\n$qrData',
      subject: loc.qr_scanner_my_code,
    );
  }

  void _saveQrCode(BuildContext context, AppLocalizations loc) {
    // TODO: 实现保存二维码到相册的功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.feature_not_ready),
      ),
    );
  }
}


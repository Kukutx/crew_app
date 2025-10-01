import 'dart:io';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:image_picker/image_picker.dart';
import '../../../../core/state/auth/auth_providers.dart';
import '../../../../core/state/avatar/avatar_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(signOutProvider)();
    if (!context.mounted) return;
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.logout_success)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final user = authState.value ?? ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile_title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // 关闭页面
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: Text(loc.my_favorites),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/favorites'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(loc.browsing_history),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/history'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: Text(loc.verification_preferences),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/preferences'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(loc.settings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: isDark ? theme.colorScheme.surface : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 只有登录状态下显示退出按钮
              if (user != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: () => _signOut(context, ref),
                    child: Text(loc.action_logout),
                  ),
                ),
              if (user != null) const SizedBox(height: 16),
              Text(
                loc.version_label('1.0.0'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final user = authState.value ?? ref.watch(currentUserProvider);

    if (user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                  radius: 32, child: Icon(Icons.person, size: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.not_logged_in, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(loc.login_prompt, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(loc.action_login),
              ),
            ],
          ),
        ),
      );
    }

    final customPath = ref.watch(avatarProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _onAvatarTap(context, ref, user),
              child: CircleAvatar(
                radius: 32,
                foregroundImage: customPath != null
                    ? FileImage(File(customPath))
                    : (user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null),
                child: (customPath == null && user.photoURL == null)
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName ?? loc.user_display_name_fallback,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(user.email ?? loc.email_unbound,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAvatarTap(
      BuildContext context, WidgetRef ref, fa.User? user) async {
    if (user == null) return;
    final loc = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.action_replace),
              onTap: () => Navigator.pop(c, 'replace'),
            ),
            if (ref.read(avatarProvider) != null)
              ListTile(
                title: Text(loc.action_restore_defaults),
                onTap: () => Navigator.pop(c, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (action == 'replace') {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        await ref.read(avatarProvider.notifier).setAvatar(img.path);
      }
    } else if (action == 'remove') {
      await ref.read(avatarProvider.notifier).clearAvatar();
    }
  }
}

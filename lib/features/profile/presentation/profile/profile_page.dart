import 'dart:io';
import 'dart:async';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:image_picker/image_picker.dart';
import '../../../../../core/state/avatar_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  fa.User? _user;
  StreamSubscription<fa.User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _user = fa.FirebaseAuth.instance.currentUser;
    // 监听用户状态变化
    _authSub = fa.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    await fa.FirebaseAuth.instance.signOut();
    if (!mounted) return;
    if (context.mounted) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.logout_success)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile_title),
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.close),
        //   onPressed: () {
        //     Navigator.of(context).pop(); // 关闭页面
        //   },
        // ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(user: _user),
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
                  leading: const Icon(Icons.event_busy),
                  title: Text(loc.my_events),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/user_event'),
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
              if (_user != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: _signOut,
                    child: Text(loc.action_logout),
                  ),
                ),
              if (_user != null) const SizedBox(height: 16),
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
  final fa.User? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

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
              onTap: () => _onAvatarTap(context, ref),
              child: CircleAvatar(
                radius: 32,
                foregroundImage: customPath != null
                    ? FileImage(File(customPath))
                    : (user!.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null),
                child: (customPath == null && user!.photoURL == null)
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user!.displayName ?? loc.user_display_name_fallback,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(user!.email ?? loc.email_unbound,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAvatarTap(BuildContext context, WidgetRef ref) async {
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

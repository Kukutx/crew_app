import 'dart:io';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/settings/data/authenticated_user_dto.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:image_picker/image_picker.dart';
import '../../../core/state/auth/auth_providers.dart';
import '../../../core/state/user/avatar/avatar_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final profileState = ref.watch(authenticatedUserProvider);
    final backendUser = profileState.asData?.value;

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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authenticatedUserProvider.notifier).refreshProfile();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 16),
            if (profileState.isLoading && backendUser == null)
              const _ProfileLoadingCard(),
            if (profileState.hasError)
              _ProfileErrorCard(
                message: _profileErrorMessage(profileState.error, loc),
                onRetry: () =>
                    ref.read(authenticatedUserProvider.notifier).refreshProfile(),
              ),
            if (backendUser != null) ...[
              _BackendProfileCard(user: backendUser, loc: loc),
              const SizedBox(height: 16),
            ],
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
      ),
      bottomNavigationBar: Container(
        color: isDark ? theme.colorScheme.surface : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Text(
            loc.version_label('1.0.0'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
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
    final profileState = ref.watch(authenticatedUserProvider);
    final backendUser = profileState.asData?.value;

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
    final displayName = _resolveDisplayName(user, backendUser, loc);
    final email = _resolveEmail(user, backendUser, loc);
    final avatarImage = _resolveAvatarImage(customPath, backendUser, user);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _onAvatarTap(context, ref, user),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 32,
                  foregroundImage: avatarImage,
                  child: avatarImage == null
                      ? const Icon(Icons.person, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(email, style: theme.textTheme.bodySmall),
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
    final customPath = ref.read(avatarProvider);
    final imageProvider = customPath != null
        ? FileImage(File(customPath)) as ImageProvider
        : (user.photoURL != null ? NetworkImage(user.photoURL!) : null);

    final action = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: .75),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _AvatarPreviewOverlay(
          imageProvider: imageProvider,
          replaceLabel: loc.action_replace,
          onReplace: () => Navigator.of(dialogContext).pop('replace'),
          restoreLabel:
              customPath != null ? loc.action_restore_defaults : null,
          onRestore: customPath != null
              ? () => Navigator.of(dialogContext).pop('remove')
              : null,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
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

class _AvatarPreviewOverlay extends StatelessWidget {
  const _AvatarPreviewOverlay({
    required this.imageProvider,
    required this.replaceLabel,
    required this.onReplace,
    this.restoreLabel,
    this.onRestore,
  });

  final ImageProvider? imageProvider;
  final String replaceLabel;
  final VoidCallback onReplace;
  final String? restoreLabel;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ZoomableAvatar(imageProvider: imageProvider),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onReplace,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: Text(replaceLabel),
                      ),
                    ),
                    if (onRestore != null && restoreLabel != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onRestore,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                        child: Text(restoreLabel!),
                      ),
                    ],
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

class _ZoomableAvatar extends StatelessWidget {
  const _ZoomableAvatar({required this.imageProvider});

  final ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    if (imageProvider == null) {
      return const Center(
        child: Hero(
          tag: 'profile_avatar',
          child: Icon(
            Icons.person,
            size: 120,
            color: Colors.white,
          ),
        ),
      );
    }

    return Hero(
      tag: 'profile_avatar',
      child: InteractiveViewer(
        maxScale: 5,
        child: Image(
          image: imageProvider!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

String _resolveDisplayName(
  fa.User user,
  AuthenticatedUserDto? backendUser,
  AppLocalizations loc,
) {
  final backendName = backendUser?.displayName?.trim();
  if (backendName != null && backendName.isNotEmpty) {
    return backendName;
  }

  final firebaseName = user.displayName?.trim();
  if (firebaseName != null && firebaseName.isNotEmpty) {
    return firebaseName;
  }

  return loc.user_display_name_fallback;
}

String _resolveEmail(
  fa.User user,
  AuthenticatedUserDto? backendUser,
  AppLocalizations loc,
) {
  final backendEmail = backendUser?.email.trim();
  if (backendEmail != null && backendEmail.isNotEmpty) {
    return backendEmail;
  }

  final firebaseEmail = user.email?.trim();
  if (firebaseEmail != null && firebaseEmail.isNotEmpty) {
    return firebaseEmail;
  }

  return loc.email_unbound;
}

ImageProvider? _resolveAvatarImage(
  String? customPath,
  AuthenticatedUserDto? backendUser,
  fa.User user,
) {
  if (customPath != null) {
    return FileImage(File(customPath));
  }

  final backendPhoto = backendUser?.photoUrl?.trim();
  if (backendPhoto != null && backendPhoto.isNotEmpty) {
    return NetworkImage(backendPhoto);
  }

  final firebasePhoto = user.photoURL?.trim();
  if (firebasePhoto != null && firebasePhoto.isNotEmpty) {
    return NetworkImage(firebasePhoto);
  }

  return null;
}

String _profileErrorMessage(Object? error, AppLocalizations loc) {
  if (error is ApiException && error.message.isNotEmpty) {
    return error.message;
  }

  if (error != null) {
    final message = error.toString().trim();
    if (message.isNotEmpty && message != 'null') {
      return message;
    }
  }

  return loc.load_failed;
}

class _ProfileLoadingCard extends StatelessWidget {
  const _ProfileLoadingCard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(loc.city_loading),
      ),
    );
  }
}

class _ProfileErrorCard extends StatelessWidget {
  const _ProfileErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.profile_sync_error,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                child: Text(loc.action_retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendProfileCard extends StatelessWidget {
  const _BackendProfileCard({
    required this.user,
    required this.loc,
  });

  final AuthenticatedUserDto user;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subscriptionLabel = user.hasActiveSubscription
        ? loc.profile_subscription_status_active
        : loc.profile_subscription_status_inactive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.settings_account_info,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: loc.settings_account_uid_label,
              value: user.id,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.mail_outline,
              label: loc.settings_account_email_label,
              value: user.email,
            ),
            const SizedBox(height: 16),
            if (user.roles.isNotEmpty) ...[
              Text(
                loc.profile_roles_label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.roles
                    .map(
                      (role) => Chip(
                        label: Text(role),
                        backgroundColor:
                            colorScheme.primaryContainer.withValues(alpha: 0.4),
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
            ],
            _InfoRow(
              icon: Icons.workspace_premium_outlined,
              label: loc.settings_subscription_current_plan,
              value: subscriptionLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

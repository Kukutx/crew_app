import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/user/presentation/pages/settings/state/settings_providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/about/about_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/blocklist/blocklist_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/developer_test/crash_test_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/developer_test/stripe_test_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/subscription/subscription_plan_page.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:crew_app/features/user/presentation/pages/support/support_feedback_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

enum LocationPermissionOption { allow, whileUsing, deny }

extension LocationPermissionOptionLabel on LocationPermissionOption {
  String label(AppLocalizations loc) {
    switch (this) {
      case LocationPermissionOption.allow:
        return loc.settings_location_permission_allow;
      case LocationPermissionOption.whileUsing:
        return loc.settings_location_permission_while_using;
      case LocationPermissionOption.deny:
        return loc.settings_location_permission_deny;
    }
  }
}

final locationPermissionProvider = StateProvider<LocationPermissionOption>(
  (ref) => LocationPermissionOption.allow,
);
final eventReminderProvider = StateProvider<bool>((ref) => true);
final followingUpdatesProvider = StateProvider<bool>((ref) => true);
final pushNotificationProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(context)!;
    final selectedLanguage = settings.locale.languageCode == 'zh' ? 'zh' : 'en';
    final currentPermission = ref.watch(locationPermissionProvider);
    final activityReminderEnabled = ref.watch(eventReminderProvider);
    final followingUpdatesEnabled = ref.watch(followingUpdatesProvider);
    final pushNotificationEnabled = ref.watch(pushNotificationProvider);
    final authState = ref.watch(authStateProvider);
    final firebaseUser = authState.value ?? ref.watch(currentUserProvider);
    final profileState = ref.watch(authenticatedUserProvider);
    final backendUser = profileState.asData?.value;
    final uid = firebaseUser != null
        ? _resolveUid(firebaseUser, backendUser)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _SettingsSection(
            title: loc.settings_section_general,
            children: [
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(loc.dark_mode),
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkMode(value);
                  _showSavedSnackBar(context, loc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(loc.language),
                trailing: DropdownButton<String>(
                  value: selectedLanguage,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    ref
                        .read(settingsProvider.notifier)
                        .setLocale(Locale(value));
                    _showSavedSnackBar(context, loc);
                  },
                  items: [
                    DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
                    DropdownMenuItem(value: 'en', child: Text(loc.english)),
                  ],
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_subscription,
            children: [
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(loc.wallet_title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed('/wallet'),
              ),
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(loc.settings_subscription_current_plan),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionPlanPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_notifications,
            children: [
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                secondary: const Icon(Icons.event_available_outlined),
                title: Text(loc.settings_notifications_activity),
                value: activityReminderEnabled,
                onChanged: (value) {
                  ref.read(eventReminderProvider.notifier).state = value;
                  _showSavedSnackBar(context, loc);
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                secondary: const Icon(Icons.people_outline),
                title: Text(loc.settings_notifications_following),
                value: followingUpdatesEnabled,
                onChanged: (value) {
                  ref.read(followingUpdatesProvider.notifier).state = value;
                  _showSavedSnackBar(context, loc);
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(loc.settings_notifications_push),
                value: pushNotificationEnabled,
                onChanged: (value) {
                  ref.read(pushNotificationProvider.notifier).state = value;
                  _showSavedSnackBar(context, loc);
                },
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_privacy,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(loc.settings_location_permission),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLocationPermissionSheet(
                  context,
                  ref,
                  loc,
                  currentPermission,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: Text(loc.settings_manage_blocklist),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlocklistPage()),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_support,
            children: [
              ListTile(
                leading: const Icon(Icons.support_agent_outlined),
                title: Text(loc.settings_help_feedback),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupportFeedbackPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(loc.settings_app_version),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0, // 暗黑里更干净
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () async {
                  final ok = await _confirmLogout(context, loc);
                  if (ok) await _signOut(context, ref);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      loc.action_logout,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (kDebugMode)
            _SettingsSection(
              title: loc.settings_section_developer,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(loc.settings_account_info),
                  subtitle: firebaseUser != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${loc.settings_account_uid_label}: $uid'),
                          ],
                        )
                      : Text(loc.login_prompt),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(loc.settings_account_delete),
                  onTap: () => _showComingSoon(context, loc),
                ),
                ListTile(
                  leading: const Icon(Icons.credit_card_outlined),
                  title: Text(loc.settings_developer_stripe_test),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StripeTestPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text("Crashlytics 模块"),
                  onTap: () async {
                    final feedbackService = ref.read(feedbackServiceProvider);
                    final submitted = await feedbackService.collectFeedback(
                      context,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    if (submitted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.feedback_thanks)),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: const Text('测试 Crashlytics'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CrashTestPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(signOutProvider)();
    if (!context.mounted) return;
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.logout_success)));
    ref.read(appOverlayIndexProvider.notifier).state = 1;
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == '/' || route.isFirst);
  }

  Future<bool> _confirmLogout(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.action_logout),
            content: Text("确认退出登录?"), // 若无该文案，可临时写死：'确认退出登录？'
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text("取消"),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text("确认"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showLocationPermissionSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    LocationPermissionOption current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in LocationPermissionOption.values)
                ListTile(
                  title: Text(option.label(loc)),
                  trailing: Icon(
                    option == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  selected: option == current,
                  onTap: () {
                    ref.read(locationPermissionProvider.notifier).state =
                        option;
                    Navigator.of(context).pop();
                    _showSavedSnackBar(context, loc);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations loc) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
  }

  void _showSavedSnackBar(BuildContext context, AppLocalizations loc) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.settings_saved_toast)));
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  if (i != 0) const Divider(height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _resolveUid(fa.User user, AuthenticatedUserDto? backendUser) {
  final backendId = backendUser?.uid.trim();
  if (backendId != null && backendId.isNotEmpty) {
    return backendId;
  }

  return user.uid;
}

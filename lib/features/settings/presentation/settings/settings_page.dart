import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/settings/settings_providers.dart';
import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:crew_app/features/settings/presentation/test/test_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum LocationPermissionOption {
  allow,
  whileUsing,
  deny,
}

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

enum SubscriptionPlan { free, plus, pro }

extension SubscriptionPlanLabel on SubscriptionPlan {
  String label(AppLocalizations loc) {
    switch (this) {
      case SubscriptionPlan.free:
        return loc.settings_subscription_plan_free;
      case SubscriptionPlan.plus:
        return loc.settings_subscription_plan_plus;
      case SubscriptionPlan.pro:
        return loc.settings_subscription_plan_pro;
    }
  }
}

final locationPermissionProvider = StateProvider<LocationPermissionOption>(
    (ref) => LocationPermissionOption.allow);
final subscriptionPlanProvider =
    StateProvider<SubscriptionPlan>((ref) => SubscriptionPlan.free);
final activityReminderProvider = StateProvider<bool>((ref) => true);
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
    final currentPlan = ref.watch(subscriptionPlanProvider);
    final activityReminderEnabled = ref.watch(activityReminderProvider);
    final followingUpdatesEnabled = ref.watch(followingUpdatesProvider);
    final pushNotificationEnabled = ref.watch(pushNotificationProvider);

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
            title: loc.settings_section_support,
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(loc.settings_help_feedback),
                subtitle: Text(loc.settings_help_feedback_subtitle),
                onTap: () async {
                  final feedbackService = ref.read(feedbackServiceProvider);
                  final submitted =
                      await feedbackService.collectFeedback(context);
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
                leading: const Icon(Icons.info_outline),
                title: Text(loc.settings_app_version),
                subtitle: Text(loc.settings_app_version_subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_subscription,
            children: [
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(loc.settings_subscription_current_plan),
                subtitle: Text(
                  loc.settings_subscription_current_plan_value(
                    currentPlan.label(loc),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSubscriptionPlanSheet(context, ref, loc),
              ),
              ListTile(
                leading: const Icon(Icons.trending_up_outlined),
                title: Text(loc.settings_subscription_upgrade),
                onTap: () => _showComingSoon(context, loc),
              ),
              ListTile(
                leading: const Icon(Icons.cancel_schedule_send_outlined),
                title: Text(loc.settings_subscription_cancel),
                onTap: () => _showComingSoon(context, loc),
              ),
              ListTile(
                leading: const Icon(Icons.credit_card_outlined),
                title: Text(loc.settings_subscription_payment_methods),
                onTap: () => _showComingSoon(context, loc),
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_privacy,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(loc.settings_location_permission),
                subtitle: Text(currentPermission.label(loc)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLocationPermissionSheet(
                    context, ref, loc, currentPermission),
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: Text(loc.settings_manage_blocklist),
                onTap: () => _showComingSoon(context, loc),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(loc.settings_privacy_documents),
                onTap: () => _showComingSoon(context, loc),
              ),
            ],
          ),
          _SettingsSection(
            title: loc.settings_section_account,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(loc.settings_account_info),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${loc.settings_account_email_label}: crew@example.com'),
                    const SizedBox(height: 4),
                    Text('${loc.settings_account_uid_label}: UID-000000'),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(loc.action_logout),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.logout_success)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(loc.settings_account_delete),
                onTap: () => _showComingSoon(context, loc),
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
                  ref.read(activityReminderProvider.notifier).state = value;
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
                subtitle: Text(loc.settings_notifications_push_subtitle),
                value: pushNotificationEnabled,
                onChanged: (value) {
                  ref.read(pushNotificationProvider.notifier).state = value;
                  _showSavedSnackBar(context, loc);
                },
              ),
            ],
          ),
          if (kDebugMode)
            _SettingsSection(
              title: loc.settings_section_developer,
              children: [
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: const Text('测试 Crashlytics'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TestPage(),
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

  void _showSubscriptionPlanSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) {
    final currentPlan = ref.read(subscriptionPlanProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final plan in SubscriptionPlan.values)
                ListTile(
                  title: Text(plan.label(loc)),
                  trailing: Icon(
                    plan == currentPlan
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  selected: plan == currentPlan,
                  onTap: () {
                    ref.read(subscriptionPlanProvider.notifier).state = plan;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.feature_not_ready)),
    );
  }

  void _showSavedSnackBar(BuildContext context, AppLocalizations loc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.settings_saved_toast)),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

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
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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

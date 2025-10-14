import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final eventReminderEnabled = ref.watch(
      settingsViewModelProvider.select((value) => value.eventReminderEnabled),
    );
    final followingUpdatesEnabled = ref.watch(
      settingsViewModelProvider.select((value) => value.followingUpdatesEnabled),
    );
    final pushNotificationEnabled = ref.watch(
      settingsViewModelProvider.select((value) => value.pushNotificationEnabled),
    );
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return SettingsSectionCard(
      title: loc.settings_section_notifications,
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          secondary: Icon(
            Icons.event_available_outlined,
            semanticLabel: loc.settings_notifications_activity,
          ),
          title: Text(loc.settings_notifications_activity),
          subtitle: Text(loc.settings_notifications_activity_subtitle),
          value: eventReminderEnabled,
          onChanged: viewModel.toggleEventReminder,
        ),
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          secondary: Icon(
            Icons.people_outline,
            semanticLabel: loc.settings_notifications_following,
          ),
          title: Text(loc.settings_notifications_following),
          subtitle: Text(loc.settings_notifications_following_subtitle),
          value: followingUpdatesEnabled,
          onChanged: viewModel.toggleFollowingUpdates,
        ),
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          secondary: Icon(
            Icons.notifications_active_outlined,
            semanticLabel: loc.settings_notifications_push,
          ),
          title: Text(loc.settings_notifications_push),
          subtitle: Text(loc.settings_notifications_push_subtitle),
          value: pushNotificationEnabled,
          onChanged: viewModel.togglePushNotification,
        ),
      ],
    );
  }
}

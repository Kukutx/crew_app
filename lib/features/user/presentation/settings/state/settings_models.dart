import 'package:crew_app/features/user/presentation/settings/state/settings_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

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

enum SettingsMessageType { saved, feedbackSubmitted, unavailable, logoutSuccess }

enum SettingsUnavailableReason {
  subscriptionUpgrade,
  subscriptionCancel,
  subscriptionPaymentMethods,
  privacyBlocklist,
  privacyDocuments,
  accountDeletion,
}

class SettingsMessage {
  const SettingsMessage._(this.type, [this.unavailableReason]);

  const SettingsMessage.saved() : this._(SettingsMessageType.saved);

  const SettingsMessage.feedbackSubmitted()
      : this._(SettingsMessageType.feedbackSubmitted);

  const SettingsMessage.unavailable(SettingsUnavailableReason reason)
      : this._(SettingsMessageType.unavailable, reason);

  const SettingsMessage.logoutSuccess()
      : this._(SettingsMessageType.logoutSuccess);

  final SettingsMessageType type;
  final SettingsUnavailableReason? unavailableReason;

  String label(AppLocalizations loc) {
    switch (type) {
      case SettingsMessageType.saved:
        return loc.settings_saved_toast;
      case SettingsMessageType.feedbackSubmitted:
        return loc.feedback_thanks;
      case SettingsMessageType.unavailable:
        final reason = unavailableReason;
        if (reason == null) {
          return loc.feature_not_ready;
        }
        switch (reason) {
          case SettingsUnavailableReason.subscriptionUpgrade:
            return loc.settings_subscription_upgrade_unavailable;
          case SettingsUnavailableReason.subscriptionCancel:
            return loc.settings_subscription_cancel_unavailable;
          case SettingsUnavailableReason.subscriptionPaymentMethods:
            return loc.settings_subscription_payment_methods_unavailable;
          case SettingsUnavailableReason.privacyBlocklist:
            return loc.settings_privacy_blocklist_unavailable;
          case SettingsUnavailableReason.privacyDocuments:
            return loc.settings_privacy_documents_unavailable;
          case SettingsUnavailableReason.accountDeletion:
            return loc.settings_account_delete_unavailable;
        }
      case SettingsMessageType.logoutSuccess:
        return loc.logout_success;
    }
  }
}

@immutable
class SettingsViewState {
  const SettingsViewState({
    required this.themeMode,
    required this.locale,
    required this.locationPermission,
    required this.subscriptionPlan,
    required this.eventReminderEnabled,
    required this.followingUpdatesEnabled,
    required this.pushNotificationEnabled,
    this.message,
  });

  factory SettingsViewState.initial(SettingsState settings) {
    return SettingsViewState(
      themeMode: settings.themeMode,
      locale: settings.locale,
      locationPermission: LocationPermissionOption.allow,
      subscriptionPlan: SubscriptionPlan.free,
      eventReminderEnabled: true,
      followingUpdatesEnabled: true,
      pushNotificationEnabled: true,
    );
  }

  final ThemeMode themeMode;
  final Locale locale;
  final LocationPermissionOption locationPermission;
  final SubscriptionPlan subscriptionPlan;
  final bool eventReminderEnabled;
  final bool followingUpdatesEnabled;
  final bool pushNotificationEnabled;
  final SettingsMessage? message;

  SettingsViewState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    LocationPermissionOption? locationPermission,
    SubscriptionPlan? subscriptionPlan,
    bool? eventReminderEnabled,
    bool? followingUpdatesEnabled,
    bool? pushNotificationEnabled,
    SettingsMessage? Function()? message,
  }) {
    return SettingsViewState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      locationPermission: locationPermission ?? this.locationPermission,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      eventReminderEnabled: eventReminderEnabled ?? this.eventReminderEnabled,
      followingUpdatesEnabled:
          followingUpdatesEnabled ?? this.followingUpdatesEnabled,
      pushNotificationEnabled:
          pushNotificationEnabled ?? this.pushNotificationEnabled,
      message: message == null ? this.message : message(),
    );
  }
}

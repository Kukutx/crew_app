import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_models.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsViewState>((ref) {
  return SettingsViewModel(ref);
});

class SettingsViewModel extends StateNotifier<SettingsViewState> {
  SettingsViewModel(this._ref)
      : super(SettingsViewState.initial(_initialSettings(_ref))) {
    _settingsListener =
        _ref.listen<SettingsState>(settingsProvider, (previous, next) {
      state = state.copyWith(
        themeMode: next.themeMode,
        locale: next.locale,
      );
    });
  }

  final Ref _ref;
  late final void Function() _settingsListener;

  Talker get _talker => _ref.read(talkerProvider);

  static SettingsState _initialSettings(Ref ref) {
    return ref.read(settingsProvider);
  }

  void _log(String event, [Map<String, Object?> payload = const {}]) {
    _talker.info('[settings] $event ${payload.isEmpty ? '' : payload}');
  }

  @override
  void dispose() {
    _settingsListener();
    super.dispose();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    state = state.copyWith(
      themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
      message: () => const SettingsMessage.saved(),
    );
    _log('dark_mode_toggled', {'enabled': enabled});
    await _ref.read(settingsProvider.notifier).setDarkMode(enabled);
  }

  Future<void> changeLocale(Locale locale) async {
    state = state.copyWith(
      locale: locale,
      message: () => const SettingsMessage.saved(),
    );
    _log('locale_changed', {'code': locale.languageCode});
    await _ref.read(settingsProvider.notifier).setLocale(locale);
  }

  void selectSubscriptionPlan(SubscriptionPlan plan) {
    state = state.copyWith(
      subscriptionPlan: plan,
      message: () => const SettingsMessage.saved(),
    );
    _log('subscription_plan_selected', {'plan': plan.name});
  }

  void updateLocationPermission(LocationPermissionOption option) {
    state = state.copyWith(
      locationPermission: option,
      message: () => const SettingsMessage.saved(),
    );
    _log('location_permission_selected', {'option': option.name});
  }

  void toggleEventReminder(bool value) {
    state = state.copyWith(
      eventReminderEnabled: value,
      message: () => const SettingsMessage.saved(),
    );
    _log('event_reminder_toggled', {'enabled': value});
  }

  void toggleFollowingUpdates(bool value) {
    state = state.copyWith(
      followingUpdatesEnabled: value,
      message: () => const SettingsMessage.saved(),
    );
    _log('following_updates_toggled', {'enabled': value});
  }

  void togglePushNotification(bool value) {
    state = state.copyWith(
      pushNotificationEnabled: value,
      message: () => const SettingsMessage.saved(),
    );
    _log('push_notifications_toggled', {'enabled': value});
  }

  Future<void> requestFeedback(BuildContext context) async {
    final feedbackService = _ref.read(feedbackServiceProvider);
    _log('feedback_opened');
    final submitted = await feedbackService.collectFeedback(context);
    if (submitted) {
      state = state.copyWith(
        message: () => const SettingsMessage.feedbackSubmitted(),
      );
      _log('feedback_submitted');
    }
  }

  void notifyUnavailable(SettingsUnavailableReason reason) {
    state = state.copyWith(
      message: () => SettingsMessage.unavailable(reason),
    );
    _log('feature_unavailable', {'reason': reason.name});
  }

  void clearMessage() {
    state = state.copyWith(message: () => null);
  }

  Future<void> signOut() async {
    _log('sign_out_requested');
    await _ref.read(signOutProvider)();
    state = state.copyWith(
      message: () => const SettingsMessage.logoutSuccess(),
    );
  }

  void trackNavigation(String target) {
    _log('navigate_$target');
  }
}

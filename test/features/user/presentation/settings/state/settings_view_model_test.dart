import 'package:crew_app/core/monitoring/feedback_service.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_models.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_providers.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _FakeFeedbackService extends FeedbackService {
  _FakeFeedbackService() : super(null, Talker());

  bool called = false;
  bool shouldSubmit = true;

  @override
  Future<bool> collectFeedback(BuildContext context) async {
    called = true;
    return shouldSubmit;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsViewModel', () {
    late SharedPreferences prefs;
    late ProviderContainer container;
    late _FakeFeedbackService feedbackService;
    late bool signOutCalled;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      feedbackService = _FakeFeedbackService();
      signOutCalled = false;
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          talkerProvider.overrideWithValue(Talker()),
          feedbackServiceProvider.overrideWithValue(feedbackService),
          signOutProvider.overrideWithValue(() async {
            signOutCalled = true;
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('toggleDarkMode updates theme and emits message', () async {
      final notifier = container.read(settingsViewModelProvider.notifier);
      await notifier.toggleDarkMode(true);
      final state = container.read(settingsViewModelProvider);

      expect(state.themeMode, ThemeMode.dark);
      expect(state.message?.type, SettingsMessageType.saved);
    });

    test('changeLocale persists locale and shows message', () async {
      final notifier = container.read(settingsViewModelProvider.notifier);
      await notifier.changeLocale(const Locale('zh'));
      final state = container.read(settingsViewModelProvider);

      expect(state.locale.languageCode, 'zh');
      expect(state.message?.type, SettingsMessageType.saved);
    });

    test('selectSubscriptionPlan updates plan', () {
      final notifier = container.read(settingsViewModelProvider.notifier);
      notifier.selectSubscriptionPlan(SubscriptionPlan.pro);
      final state = container.read(settingsViewModelProvider);

      expect(state.subscriptionPlan, SubscriptionPlan.pro);
      expect(state.message?.type, SettingsMessageType.saved);
    });

    test('notifyUnavailable emits unavailable message', () {
      final notifier = container.read(settingsViewModelProvider.notifier);
      notifier.notifyUnavailable(SettingsUnavailableReason.accountDeletion);
      final state = container.read(settingsViewModelProvider);

      expect(state.message?.type, SettingsMessageType.unavailable);
      expect(
        state.message?.unavailableReason,
        SettingsUnavailableReason.accountDeletion,
      );
    });

    test('toggle notification switches update state', () {
      final notifier = container.read(settingsViewModelProvider.notifier);
      notifier.toggleEventReminder(false);
      notifier.toggleFollowingUpdates(false);
      notifier.togglePushNotification(false);
      final state = container.read(settingsViewModelProvider);

      expect(state.eventReminderEnabled, isFalse);
      expect(state.followingUpdatesEnabled, isFalse);
      expect(state.pushNotificationEnabled, isFalse);
    });

    test('requestFeedback triggers feedback flow and message', () async {
      final notifier = container.read(settingsViewModelProvider.notifier);
      await notifier.requestFeedback(
        const FeedbackTestContext(),
      );
      final state = container.read(settingsViewModelProvider);

      expect(feedbackService.called, isTrue);
      expect(state.message?.type, SettingsMessageType.feedbackSubmitted);
    });

    test('signOut delegates to provider and shows toast message', () async {
      final notifier = container.read(settingsViewModelProvider.notifier);
      await notifier.signOut();
      final state = container.read(settingsViewModelProvider);

      expect(signOutCalled, isTrue);
      expect(state.message?.type, SettingsMessageType.logoutSuccess);
    });

    test('clearMessage removes current message', () {
      final notifier = container.read(settingsViewModelProvider.notifier);
      notifier.selectSubscriptionPlan(SubscriptionPlan.plus);
      notifier.clearMessage();
      final state = container.read(settingsViewModelProvider);

      expect(state.message, isNull);
    });
  });
}

class FeedbackTestContext extends BuildContext {
  const FeedbackTestContext();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:crew_app/core/monitoring/feedback_service.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/account_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/developer_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/general_settings_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/notification_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/privacy_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/subscription_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/support_section.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_providers.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_navigator.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _FakeFeedbackService extends FeedbackService {
  _FakeFeedbackService() : super(null, Talker());

  @override
  Future<bool> collectFeedback(BuildContext context) async => false;
}

class _FakeAuthenticatedUserNotifier
    extends StateNotifier<AsyncValue<AuthenticatedUserDto?>> {
  _FakeAuthenticatedUserNotifier() : super(const AsyncValue.data(null));
}

Future<ProviderContainer> _pumpSection(
  WidgetTester tester,
  Widget section, {
  List<Override> extraOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final overrides = <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
    talkerProvider.overrideWithValue(Talker()),
    feedbackServiceProvider.overrideWithValue(_FakeFeedbackService()),
    signOutProvider.overrideWithValue(() async {}),
    settingsNavigatorProvider.overrideWithValue(const SettingsNavigator()),
    ...extraOverrides,
  ];

  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: Consumer(
        builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: section),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GeneralSettingsSection displays localized labels', (tester) async {
    await _pumpSection(tester, const GeneralSettingsSection());

    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('SupportSection shows support actions', (tester) async {
    await _pumpSection(tester, const SupportSection());

    expect(find.text('Help & feedback'), findsOneWidget);
    expect(find.text('App version'), findsOneWidget);
  });

  testWidgets('SubscriptionSection renders current plan', (tester) async {
    final container = await _pumpSection(tester, const SubscriptionSection());
    final viewModel = container.read(settingsViewModelProvider.notifier);
    viewModel.selectSubscriptionPlan(SubscriptionPlan.plus);
    await tester.pumpAndSettle();

    expect(find.textContaining('Plus plan'), findsOneWidget);
  });

  testWidgets('PrivacySection shows location permission value', (tester) async {
    await _pumpSection(tester, const PrivacySection());

    expect(find.text('Location permission'), findsOneWidget);
    expect(find.text('Allow location access'), findsOneWidget);
  });

  testWidgets('NotificationSection toggles default to enabled', (tester) async {
    await _pumpSection(tester, const NotificationSection());

    final switches = tester.widgetList<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switches.every((tile) => tile.value), isTrue);
  });

  testWidgets('DeveloperSection displays crash test entry', (tester) async {
    await _pumpSection(tester, const DeveloperSection());

    expect(find.text('测试 Crashlytics'), findsOneWidget);
  });

  testWidgets('AccountSection renders login prompt when signed out',
      (tester) async {
    final container = await _pumpSection(
      tester,
      const AccountSection(),
      extraOverrides: [
        authStateProvider.overrideWithValue(const AsyncValue.data<User?>(null)),
        currentUserProvider.overrideWithValue(null),
        authenticatedUserProvider.overrideWith((ref) {
          return _FakeAuthenticatedUserNotifier();
        }),
      ],
    );
    container.read(settingsViewModelProvider); // ensure initialization
    await tester.pumpAndSettle();

    expect(find.textContaining('sign in'), findsOneWidget);
  });
}

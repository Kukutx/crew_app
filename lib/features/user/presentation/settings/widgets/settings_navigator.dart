import 'package:crew_app/features/user/presentation/settings/pages/about/about_page.dart';
import 'package:crew_app/features/user/presentation/settings/pages/developer_test/crash_test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SettingsRoute { history, preferences, login }

extension SettingsRoutePath on SettingsRoute {
  String get path {
    switch (this) {
      case SettingsRoute.history:
        return '/history';
      case SettingsRoute.preferences:
        return '/preferences';
      case SettingsRoute.login:
        return '/login';
    }
  }
}

final settingsNavigatorProvider = Provider<SettingsNavigator>((ref) {
  return const SettingsNavigator();
});

class SettingsNavigator {
  const SettingsNavigator();

  Future<void> openAbout(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  Future<void> openCrashTest(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CrashTestPage()),
    );
  }

  Future<void> openNamed(BuildContext context, SettingsRoute route) {
    return Navigator.of(context).pushNamed(route.path);
  }
}

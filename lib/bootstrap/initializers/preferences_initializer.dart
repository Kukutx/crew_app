import 'package:shared_preferences/shared_preferences.dart';

class PreferencesInitializer {
  const PreferencesInitializer();

  Future<SharedPreferences> initialize() {
    return SharedPreferences.getInstance();
  }
}

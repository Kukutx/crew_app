import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crew_app/core/storage/shared_preferences_provider.dart';

// ---------- Settings ----------
class SettingsState {
  const SettingsState({
    required this.locale,
    required this.themeMode,
  });

  final Locale locale;
  final ThemeMode themeMode;

  SettingsState copyWith({Locale? locale, ThemeMode? themeMode}) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs)
      : super(
          SettingsState(
            locale: _resolveLocale(_prefs.getString(_kLangKey)),
            themeMode: _prefs.getBool(_kDarkKey) ?? false
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
        );
  static const _kLangKey = 'language';
  static const _kDarkKey = 'darkMode';

  final SharedPreferences _prefs;

  static Locale _resolveLocale(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return PlatformDispatcher.instance.locale;
    }
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_kLangKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_kDarkKey, value);
    state = state.copyWith(
      themeMode: value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
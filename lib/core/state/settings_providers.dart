import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ---------- Settings ----------
class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;
  const SettingsState({required this.locale, required this.themeMode});
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  static const _kLang = 'language';
  static const _kDark = 'darkMode';

  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();

    final langCode = prefs.getString(_kLang);
    final locale = langCode != null
        ? Locale(langCode)
        : PlatformDispatcher.instance.locale;

    final dark = prefs.getBool(_kDark) ?? false;
    return SettingsState(
      locale: locale,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, locale.languageCode);
    state = AsyncData(SettingsState(
      locale: locale,
      themeMode: state.value?.themeMode ?? ThemeMode.system,
    ));
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, value);
    final curr = state.value!;
    state = AsyncData(SettingsState(
      locale: curr.locale,
      themeMode: value ? ThemeMode.dark : ThemeMode.light,
    ));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(() => SettingsNotifier());

// ---------- Auth ----------
final authStateProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

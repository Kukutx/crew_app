import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_providers.dart';

class AvatarNotifier extends StateNotifier<String?> {
  AvatarNotifier(this._uid) : super(null) {
    if (_uid != null) {
      _load();
    }
  }

  final String? _uid;
  static const _prefix = 'customAvatar_';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('$_prefix$_uid');
  }

  Future<void> setAvatar(String path) async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$_uid', path);
    state = path;
  }

  Future<void> clearAvatar() async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$_uid');
    state = null;
  }
}

final avatarProvider =
    StateNotifierProvider<AvatarNotifier, String?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return AvatarNotifier(uid);
});
import 'dart:convert';

import 'package:crew_app/features/legal/domain/models/disclaimer.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kCacheKey = 'legal.disclaimer.cached.json';
const _kAcceptedVersionKey = 'legal.disclaimer.accepted.version';

class LocalCacheDisclaimerSource {
  Future<Disclaimer?> loadCached() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kCacheKey);
    if (raw == null) return null;
    return Disclaimer.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> saveCached(Disclaimer d) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kCacheKey, json.encode(d.toJson()));
  }

  Future<int> loadAcceptedVersion() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kAcceptedVersionKey) ?? 0;
  }

  Future<void> saveAcceptedVersion(int v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kAcceptedVersionKey, v);
  }
}

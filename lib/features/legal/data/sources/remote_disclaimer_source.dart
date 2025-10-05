import 'dart:convert';

import 'package:crew_app/core/config/remote_config_keys.dart';
import 'package:crew_app/features/legal/domain/models/disclaimer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// 线上版本：二选一 —— Firebase Remote Config 或 你自家 API
abstract class RemoteDisclaimerSource {
  Future<Disclaimer?> fetchLatest();
}

class RemoteConfigDisclaimerSource implements RemoteDisclaimerSource {
  RemoteConfigDisclaimerSource(this._remoteConfig, {Talker? talker}) : _talker = talker;

  final FirebaseRemoteConfig _remoteConfig;
  final Talker? _talker;

  @override
  Future<Disclaimer?> fetchLatest() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (error, stackTrace) {
      _talker?.handle(error, stackTrace, 'remote_config.fetch_disclaimer');
    }

    final raw = _remoteConfig.getString(RemoteConfigKeys.disclaimerJson);
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '{}') {
      return null;
    }

    try {
      return Disclaimer.fromJson(json.decode(trimmed) as Map<String, dynamic>);
    } catch (error, stackTrace) {
      _talker?.handle(error, stackTrace, 'remote_config.parse_disclaimer');
      return null;
    }
  }
}

class NoopRemoteDisclaimerSource implements RemoteDisclaimerSource {
  const NoopRemoteDisclaimerSource();

  @override
  Future<Disclaimer?> fetchLatest() async => null;
}

/// 例：你自己的 API（用 Dio/Http 请求拿 JSON）
class ApiDisclaimerSource implements RemoteDisclaimerSource {
  @override
  Future<Disclaimer?> fetchLatest() async {
    // final res = await dio.get('/legal/disclaimer');
    // return Disclaimer.fromJson(res.data);
    return null;
  }
}

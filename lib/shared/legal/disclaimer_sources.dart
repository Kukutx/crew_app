// 数据源与仓库（缓存 + 线上拉取）
/* 启动时并行：读本地缓存（上次已同意的版本）+ 拉线上配置（Firebase Remote Config 或你自己的 API）；
  若线上版本号 > 已同意版本号 → 弹出对话框，用户同意后把“已同意版本号”写入本地；
  离线时：展示缓存的上次线上内容。
  */

import 'dart:convert';
import 'package:crew_app/core/config/remote_config_keys.dart';
import 'package:crew_app/shared/legal/data/disclaimer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';


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

/// 线上版本：二选一 —— Firebase Remote Config 或 你自家 API
abstract class RemoteDisclaimerSource {
  Future<Disclaimer?> fetchLatest();
}

class RemoteConfigDisclaimerSource implements RemoteDisclaimerSource {
  RemoteConfigDisclaimerSource(this._remoteConfig, {Talker? talker})
      : _talker = talker;

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

class DisclaimerRepository {
  DisclaimerRepository({
    required this.cache,
    required this.remote,
  });

  final LocalCacheDisclaimerSource cache;
  final RemoteDisclaimerSource remote;

  /// 启动时使用：先拿**可展示**版本（缓存），并尝试后台拉取线上
  Future<({Disclaimer? show, Disclaimer? latest, int acceptedVersion})> bootstrap() async {
    final cached = await cache.loadCached();
    Disclaimer? show = cached;
    final accepted = await cache.loadAcceptedVersion();

    Disclaimer? latest;
    try {
      latest = await remote.fetchLatest();
      if (latest != null) {
        await cache.saveCached(latest);
        show = latest;
      }
    } catch (_) {
      // 静默失败，保留 show
    }
    return (show: show, latest: latest, acceptedVersion: accepted);
  }

  Future<void> markAccepted(int version) => cache.saveAcceptedVersion(version);
}

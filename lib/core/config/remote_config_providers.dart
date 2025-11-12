import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Remote Config provider (可能为 null，如果初始化失败)
/// 由 Bootstrapper 通过 overrideWithValue 初始化
final remoteConfigProvider = Provider<FirebaseRemoteConfig?>((ref) => null);

import 'package:crew_app/core/monitoring/feedback_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Crashlytics provider (可能为 null，如果 Firebase 初始化失败)
/// 由 Bootstrapper 通过 overrideWithValue 初始化
final crashlyticsProvider = Provider<FirebaseCrashlytics?>((ref) => null);

/// Talker logger provider
/// 由 Bootstrapper 通过 overrideWithValue 初始化
final talkerProvider = Provider<Talker>((ref) {
  throw StateError('Talker must be initialized in Bootstrapper');
});

/// Talker route observer provider
/// 由 Bootstrapper 通过 overrideWithValue 初始化
final talkerRouteObserverProvider = Provider<TalkerRouteObserver>((ref) {
  throw StateError('TalkerRouteObserver must be initialized in Bootstrapper');
});

/// Feedback service provider
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(
    ref.watch(crashlyticsProvider),
    ref.watch(talkerProvider),
  );
});

import 'package:crew_app/core/monitoring/feedback_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

final crashlyticsProvider = Provider<FirebaseCrashlytics?>((ref) => null);

final talkerProvider = Provider<Talker>((ref) {
  throw UnimplementedError('talkerProvider must be overridden at the root');
});

final talkerRouteObserverProvider = Provider<TalkerRouteObserver>((ref) {
  throw UnimplementedError(
    'talkerRouteObserverProvider must be overridden at the root',
  );
});

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final crashlytics = ref.watch(crashlyticsProvider);
  final talker = ref.watch(talkerProvider);
  return FeedbackService(crashlytics, talker);
});

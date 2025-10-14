import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef FullScreenOpener = Future<int?> Function();
typedef FullScreenResultHandler = void Function(int? result);

class EventDetailInteractionController {
  EventDetailInteractionController({
    required this.eventId,
    required this.openFullScreen,
    required this.onFullScreenClosed,
  });

  final String eventId;
  final FullScreenOpener openFullScreen;
  final FullScreenResultHandler onFullScreenClosed;

  bool _opening = false;

  bool get isOpening => _opening;

  Future<void> handleStretchProgress(double progress) async {
    if (progress < 1) {
      return;
    }
    await _triggerFullScreen('stretch');
  }

  Future<void> handleTap() => _triggerFullScreen('tap');

  Future<void> handleDragEndVelocity(double velocity) async {
    if (velocity < -650) {
      await _triggerFullScreen('swipe');
    }
  }

  Future<void> _triggerFullScreen(String source) async {
    if (_opening) {
      return;
    }
    _opening = true;
    debugPrint('Analytics: event_fullscreen_threshold_\${eventId}_\$source');
    HapticFeedback.mediumImpact();
    try {
      final result = await openFullScreen();
      onFullScreenClosed(result);
    } finally {
      _opening = false;
    }
  }
}

import 'dart:math';

import 'package:feedback/feedback.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class FeedbackService {
  FeedbackService(this._crashlytics, this._talker);

  static const _maxLoggedMessageLength = 1000;

  final FirebaseCrashlytics? _crashlytics;
  final Talker _talker;

  Future<bool> collectFeedback(BuildContext context) async {
    final controller = BetterFeedback.of(context);
    if (controller == null) {
      _talker.warning('Feedback controller is not available in the widget tree.');
      return false;
    }

    final feedback = await controller.show();
    if (feedback == null) {
      _talker.info('User dismissed the feedback reporter.');
      return false;
    }

    final message = feedback.text?.trim() ?? '';
    final screenshotLength = feedback.screenshot?.length ?? 0;

    if (message.isNotEmpty) {
      _talker.info('User feedback captured (${message.length} chars).');
    } else {
      _talker.info('User submitted feedback without a description.');
    }

    if (screenshotLength > 0) {
      _talker.info('Feedback screenshot captured ($screenshotLength bytes).');
    }

    await _logFeedbackToCrashlytics(message, screenshotLength);
    return true;
  }

  Future<void> _logFeedbackToCrashlytics(String message, int screenshotLength) async {
    if (_crashlytics == null) {
      return;
    }

    final truncatedMessage = message.substring(
      0,
      min(message.length, _maxLoggedMessageLength),
    );

    await _crashlytics!.log(
      'User feedback: ${truncatedMessage.isEmpty ? '<empty>' : truncatedMessage}',
    );
    await _crashlytics!.setCustomKey('feedback_message_length', message.length);
    await _crashlytics!.setCustomKey('feedback_screenshot_bytes', screenshotLength);
    await _crashlytics!.recordError(
      _FeedbackException(truncatedMessage),
      null,
      reason: 'User Feedback',
      information: [
        'messageLength=${message.length}',
        'hasScreenshot=${screenshotLength > 0}',
      ],
      fatal: false,
    );
  }
}

class _FeedbackException implements Exception {
  _FeedbackException(this.message);

  final String message;

  @override
  String toString() => 'FeedbackException: $message';
}

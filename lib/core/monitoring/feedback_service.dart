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

  /// 弹出反馈面板并在提交后记录日志与上报
  Future<bool> collectFeedback(BuildContext context) async {
    final controller = BetterFeedback.of(context);

    final feedback = await controller.showAndGetUserFeedback();
    if (feedback == null) {
      _talker.info('User dismissed feedback overlay without submitting.');
      return false;
    }

    final message = feedback.text.trim();
    final screenshotLength = feedback.screenshot.length;

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
    final crash = _crashlytics;
    if (crash == null) return;

    final truncated = message.substring(0, min(message.length, _maxLoggedMessageLength));

    await crash.log('User feedback: ${truncated.isEmpty ? '<empty>' : truncated}');
    await crash.setCustomKey('feedback_message_length', message.length);
    await crash.setCustomKey('feedback_screenshot_bytes', screenshotLength);

    await crash.recordError(
      _FeedbackException(truncated),
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

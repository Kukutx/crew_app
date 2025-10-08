import 'package:flutter/material.dart';

class MessagesChatPreview {
  const MessagesChatPreview({
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.accentColor,
    this.status,
    this.timeText,
    this.unreadCount = 0,
  });

  final String title;
  final String subtitle;
  final List<String> tags;
  final Color accentColor;
  final String? status;
  final String? timeText;
  final int unreadCount;
}

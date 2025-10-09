import 'package:flutter/material.dart';

class DirectMessagePreview {
  const DirectMessagePreview({
    required this.name,
    required this.subtitle,
    required this.timestamp,
    this.initials,
    this.avatarColor,
    this.isActive = false,
    this.isUnread = false,
    this.subtitleColor,
  });

  final String name;
  final String subtitle;
  final String timestamp;
  final String? initials;
  final Color? avatarColor;
  final bool isActive;
  final bool isUnread;
  final Color? subtitleColor;
}

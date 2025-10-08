import 'package:flutter/material.dart';

class DirectMessageStory {
  const DirectMessageStory({
    required this.title,
    this.subtitle,
    this.gradient,
    this.icon,
    this.badgeLabel,
    this.badgeColor,
  });

  final String title;
  final String? subtitle;
  final LinearGradient? gradient;
  final IconData? icon;
  final String? badgeLabel;
  final Color? badgeColor;
}

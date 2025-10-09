import 'package:flutter/material.dart';

class MessagesChatParticipant {
  const MessagesChatParticipant({
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.isSelf = false,
  });

  final String name;
  final String initials;
  final Color avatarColor;
  final bool isSelf;
}

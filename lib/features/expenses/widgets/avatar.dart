import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.isPrimary = false,
  });

  final String name;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final initials = name.isEmpty
        ? ''
        : name.trim().split(RegExp(r'\s+')).map((part) => part[0]).take(2).join();
    return CrewAvatar(
      radius: isPrimary ? 32 : 24,
      backgroundColor:
          isPrimary ? Colors.white.withValues(alpha: .24) : const Color(0xFF1B8A5C),
      foregroundColor: Colors.white,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

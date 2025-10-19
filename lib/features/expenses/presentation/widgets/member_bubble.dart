import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/expense.dart';

class MemberBubble extends StatelessWidget {
  MemberBubble({
    super.key,
    required this.member,
    required this.radius,
    required this.color,
    required this.onTap,
  }) : _formatter = NumberFormat.currency(symbol: '€');

  final Member member;
  final double radius;
  final Color color;
  final VoidCallback onTap;
  final NumberFormat _formatter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amount = _formatter.format(member.total);
    return Semantics(
      label: '${member.name} $amount',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (member.avatarUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(member.avatarUrl!),
                  radius: radius * 0.35,
                ),
              if (member.avatarUrl != null) const SizedBox(height: 8),
              Text(
                member.name,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

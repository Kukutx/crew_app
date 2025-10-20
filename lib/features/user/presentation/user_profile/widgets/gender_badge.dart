import 'package:flutter/material.dart';

import 'package:crew_app/features/user/data/user.dart';

class GenderBadge extends StatelessWidget {
  const GenderBadge({
    super.key,
    required this.gender,
    this.size = 24,
  });

  final Gender gender;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = _badgeGradient(gender);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: size * 0.45,
            offset: Offset(0, size * 0.18),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        gender.emoji,
        style: TextStyle(
          fontSize: size * 0.6,
          height: 1,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Color> _badgeGradient(Gender gender) {
    switch (gender) {
      case Gender.female:
        return const [Color(0xFFFF7AD5), Color(0xFFFFB7E2)];
      case Gender.male:
        return const [Color(0xFF6AA9FF), Color(0xFF92E4FF)];
      case Gender.undisclosed:
        return const [Color(0xFFB4B5FF), Color(0xFFE1E1FF)];
    }
  }
}

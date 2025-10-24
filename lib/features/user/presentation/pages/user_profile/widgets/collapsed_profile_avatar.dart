import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

import 'package:crew_app/features/user/data/user.dart';

class CollapsedProfileAvatar extends StatelessWidget {
  const CollapsedProfileAvatar({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CrewAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(user.avatar),
              borderRadius: BorderRadius.circular(18),
            ),
            if (user.countryFlag != null)
              Positioned(
                bottom: -6,
                right: -6,
                child: Text(
                  user.countryFlag!,
                  style: const TextStyle(
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black38,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

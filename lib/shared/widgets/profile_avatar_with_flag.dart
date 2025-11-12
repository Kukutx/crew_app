import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:crew_app/shared/widgets/crew_avatar.dart';

/// 带国旗的用户头像组件
/// 用于在用户资料中显示头像和国旗
class ProfileAvatarWithFlag extends StatelessWidget {
  const ProfileAvatarWithFlag({
    super.key,
    required this.avatarUrl,
    this.flagEmoji,
    this.radius = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.onTap,
  });

  final String? avatarUrl;
  final String? flagEmoji;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        Colors.white.withValues(alpha: 0.12);
    final effectiveFgColor = foregroundColor ?? Colors.white;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(28);

    Widget avatar = CrewAvatar(
      radius: radius,
      backgroundImage: avatarUrl != null
          ? CachedNetworkImageProvider(avatarUrl!)
          : null,
      backgroundColor: effectiveBgColor,
      foregroundColor: effectiveFgColor,
      borderRadius: effectiveBorderRadius,
      child: avatarUrl == null
          ? Icon(Icons.person_outline, size: radius * 0.7)
          : null,
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    if (flagEmoji == null) {
      return avatar;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: -6,
          left: -6,
          child: Text(
            flagEmoji!,
            style: TextStyle(
              fontSize: radius * 0.6,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


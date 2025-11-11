import 'package:flutter/material.dart';

/// 用户资料标签组件
/// 用于显示用户标签
class ProfileTagChip extends StatelessWidget {
  const ProfileTagChip({
    super.key,
    required this.tag,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  final String tag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? Colors.white.withValues(alpha: 0.15);
    final fgColor = foregroundColor ?? Colors.white;
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        );
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(10);

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: theme.textTheme.labelMedium?.copyWith(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceVariant = colorScheme.surfaceContainerHighest;
    final baseSurface = colorScheme.surface;
    final opacity = colorScheme.brightness == Brightness.dark ? 0.25 : 0.6;
    final backgroundColor = Color.alphaBlend(
      surfaceVariant.withValues(alpha: opacity),
      baseSurface,
    );
    final borderOpacity = colorScheme.brightness == Brightness.dark ? 0.2 : 0.35;
    final borderColor = colorScheme.outlineVariant.withValues(alpha: borderOpacity);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.heroTag,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Object? heroTag;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: margin,
      child: FloatingActionButton.small(
        heroTag: heroTag,
        onPressed: onPressed,
        elevation: elevation,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

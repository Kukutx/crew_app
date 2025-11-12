import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

enum AppFloatingActionButtonVariant { small, regular, extended }

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.heroTag,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.shape,
    this.variant = AppFloatingActionButtonVariant.small,
  });

  final VoidCallback onPressed;
  final Widget? child;
  final Widget? label;
  final Widget? icon;
  final Object? heroTag;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final ShapeBorder? shape;
  final AppFloatingActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? theme.colorScheme.onPrimary;
    final ShapeBorder defaultShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r));
    final effectiveShape = shape ?? defaultShape;

    final Widget button;
    switch (variant) {
      case AppFloatingActionButtonVariant.small:
        button = FloatingActionButton.small(
          heroTag: heroTag,
          onPressed: onPressed,
          tooltip: tooltip,
          elevation: elevation,
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          shape: effectiveShape,
          child: child!,
        );
        break;
      case AppFloatingActionButtonVariant.regular:
        button = FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          tooltip: tooltip,
          elevation: elevation,
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          shape: effectiveShape,
          child: child!,
        );
        break;
      case AppFloatingActionButtonVariant.extended:
        button = FloatingActionButton.extended(
          heroTag: heroTag,
          onPressed: onPressed,
          tooltip: tooltip,
          elevation: elevation,
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          shape: effectiveShape,
          icon: icon,
          label: label!,
        );
        break;
    }

    return Padding(
      padding: margin,
      child: button,
    );
  }
}

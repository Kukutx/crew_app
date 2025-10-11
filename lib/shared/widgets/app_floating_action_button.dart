import 'dart:math' as math;

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
    this.enableBottomNavigationBarAdjustment = true,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Object? heroTag;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableBottomNavigationBarAdjustment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction = Directionality.of(context);
    final resolvedMargin = margin.resolve(direction);
    final scaffoldState = Scaffold.maybeOf(context);
    final geometry = scaffoldState?.geometry;
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    double bottomInset = resolvedMargin.bottom;

    if (enableBottomNavigationBarAdjustment) {
      final bottomNavigationBarTop = geometry?.bottomNavigationBarTop;
      if (bottomNavigationBarTop != null) {
        final navigationBarHeight =
            (screenHeight - bottomNavigationBarTop).clamp(0.0, double.infinity);
        bottomInset += math.max(navigationBarHeight, viewPadding);
      } else if (scaffoldState?.widget.bottomNavigationBar != null) {
        const estimatedNavigationBarHeight = 88.0;
        bottomInset += viewPadding + estimatedNavigationBarHeight;
      } else {
        bottomInset += viewPadding;
      }
    } else {
      bottomInset += viewPadding;
    }

    final effectiveMargin = resolvedMargin.copyWith(bottom: bottomInset);

    return Padding(
      padding: effectiveMargin,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        elevation: elevation,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        shape: const StadiumBorder(),
        child: child,
      ),
    );
  }
}

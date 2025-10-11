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
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;

    double bottomInset = resolvedMargin.bottom;

    if (enableBottomNavigationBarAdjustment) {
      final navigationBarHeight = _inferBottomNavigationBarHeight(
        context,
        scaffoldState?.widget.bottomNavigationBar,
      );

      bottomInset += viewPadding + navigationBarHeight;
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

/// Best-effort estimation of the vertical space taken by [bottomNavigationBar].
///
/// When the widget does not expose an explicit size, the fallback height keeps
/// enough room for common Material navigation components.
double _inferBottomNavigationBarHeight(
  BuildContext context,
  Widget? bottomNavigationBar,
) {
  if (bottomNavigationBar == null) {
    return 0;
  }

  if (bottomNavigationBar is PreferredSizeWidget) {
    return bottomNavigationBar.preferredSize.height;
  }

  if (bottomNavigationBar is NavigationBar) {
    final themedHeight = NavigationBarTheme.of(context).height;
    return bottomNavigationBar.height ?? themedHeight ?? _kDefaultNavigationBarHeight;
  }

  if (bottomNavigationBar is BottomNavigationBar) {
    return kBottomNavigationBarHeight;
  }

  if (bottomNavigationBar is SizedBox && bottomNavigationBar.height != null) {
    return bottomNavigationBar.height!;
  }

  return _kDefaultNavigationBarHeight;
}

const double _kDefaultNavigationBarHeight = 88.0;

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
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;

    double bottomInset = resolvedMargin.bottom;

    if (enableBottomNavigationBarAdjustment) {
      final navigationBarMetrics = _inferBottomNavigationBarMetrics(
        context,
        scaffoldState?.widget.bottomNavigationBar,
      );

      bottomInset += navigationBarMetrics.height;

      if (!navigationBarMetrics.consumesViewPadding) {
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

_NavigationBarMetrics _inferBottomNavigationBarMetrics(
  BuildContext context,
  Widget? bottomNavigationBar,
) {
  if (bottomNavigationBar == null) {
    return const _NavigationBarMetrics.zero();
  }

  final estimate = _NavigationBarMetricsVisitor(context).estimate(bottomNavigationBar);

  if (estimate != null) {
    return estimate;
  }

  final viewPadding = MediaQuery.viewPaddingOf(context).bottom;

  return _NavigationBarMetrics(
    height: viewPadding + _kDefaultNavigationBarHeight,
    consumesViewPadding: true,
  );
}

class _NavigationBarMetrics {
  const _NavigationBarMetrics({
    required this.height,
    required this.consumesViewPadding,
  });

  const _NavigationBarMetrics.zero()
      : height = 0,
        consumesViewPadding = false;

  final double height;
  final bool consumesViewPadding;
}

class _NavigationBarMetricsVisitor {
  _NavigationBarMetricsVisitor(this.context)
      : _viewPadding = MediaQuery.viewPaddingOf(context).bottom,
        _direction = Directionality.of(context);

  final BuildContext context;
  final double _viewPadding;
  final TextDirection _direction;

  _NavigationBarMetrics? estimate(Widget? widget) {
    if (widget == null) {
      return const _NavigationBarMetrics.zero();
    }

    return switch (widget) {
      PreferredSizeWidget preferredSizeWidget => _fromPreferredSizeWidget(preferredSizeWidget),
      NavigationBar navigationBar => _fromNavigationBar(navigationBar),
      BottomNavigationBar _ => const _NavigationBarMetrics(
          height: kBottomNavigationBarHeight,
          consumesViewPadding: false,
        ),
      SafeArea safeArea => _fromSafeArea(safeArea),
      Padding padding => _fromPadding(padding),
      Align align => estimate(align.child),
      FractionallySizedBox fractionallySizedBox => estimate(fractionallySizedBox.child),
      ClipRRect clipRRect => estimate(clipRRect.child),
      ClipRect clipRect => estimate(clipRect.child),
      BackdropFilter backdropFilter => estimate(backdropFilter.child),
      DecoratedBox decoratedBox => estimate(decoratedBox.child),
      InheritedWidget inheritedWidget => estimate(inheritedWidget.child),
      Container container => _fromContainer(container),
      AnimatedContainer animatedContainer => _fromAnimatedContainer(animatedContainer),
      SizedBox sizedBox => _fromSizedBox(sizedBox),
      ConstrainedBox constrainedBox => _fromConstrainedBox(constrainedBox),
      _ => null,
    };
  }

  _NavigationBarMetrics _fromPreferredSizeWidget(PreferredSizeWidget widget) {
    return _NavigationBarMetrics(
      height: widget.preferredSize.height,
      consumesViewPadding: false,
    );
  }

  _NavigationBarMetrics _fromNavigationBar(NavigationBar navigationBar) {
    final themedHeight = NavigationBarTheme.of(context).height;

    return _NavigationBarMetrics(
      height: navigationBar.height ?? themedHeight ?? _kDefaultNavigationBarHeight,
      consumesViewPadding: false,
    );
  }

  _NavigationBarMetrics? _fromSafeArea(SafeArea safeArea) {
    final childEstimate = estimate(safeArea.child);
    if (childEstimate == null) {
      return null;
    }

    final minimum = safeArea.minimum.resolve(_direction).bottom;
    final bottomPadding = math.max(_viewPadding, minimum);

    return _NavigationBarMetrics(
      height: bottomPadding + childEstimate.height,
      consumesViewPadding: true,
    );
  }

  _NavigationBarMetrics? _fromPadding(Padding padding) {
    final childEstimate = estimate(padding.child);
    if (childEstimate == null) {
      return null;
    }

    final resolvedPadding = padding.padding.resolve(_direction);

    return _NavigationBarMetrics(
      height: resolvedPadding.vertical + childEstimate.height,
      consumesViewPadding: childEstimate.consumesViewPadding,
    );
  }

  _NavigationBarMetrics? _fromContainer(Container container) {
    final resolvedPadding = container.padding?.resolve(_direction);
    final paddingHeight = resolvedPadding?.vertical ?? 0;

    final constraints = container.constraints;
    if (constraints != null && constraints.hasTightHeight) {
      return _NavigationBarMetrics(
        height: paddingHeight + constraints.maxHeight,
        consumesViewPadding: false,
      );
    }

    if (container.height != null) {
      return _NavigationBarMetrics(
        height: paddingHeight + container.height!,
        consumesViewPadding: false,
      );
    }

    final childEstimate = estimate(container.child);
    if (childEstimate == null) {
      return null;
    }

    return _NavigationBarMetrics(
      height: paddingHeight + childEstimate.height,
      consumesViewPadding: childEstimate.consumesViewPadding,
    );
  }

  _NavigationBarMetrics? _fromAnimatedContainer(AnimatedContainer animatedContainer) {
    final resolvedPadding = animatedContainer.padding?.resolve(_direction);
    final paddingHeight = resolvedPadding?.vertical ?? 0;

    final constraints = animatedContainer.constraints;
    if (constraints != null && constraints.hasTightHeight) {
      return _NavigationBarMetrics(
        height: paddingHeight + constraints.maxHeight,
        consumesViewPadding: false,
      );
    }

    if (animatedContainer.height != null) {
      return _NavigationBarMetrics(
        height: paddingHeight + animatedContainer.height!,
        consumesViewPadding: false,
      );
    }

    final childEstimate = estimate(animatedContainer.child);
    if (childEstimate == null) {
      return null;
    }

    return _NavigationBarMetrics(
      height: paddingHeight + childEstimate.height,
      consumesViewPadding: childEstimate.consumesViewPadding,
    );
  }

  _NavigationBarMetrics? _fromSizedBox(SizedBox sizedBox) {
    if (sizedBox.height != null) {
      return _NavigationBarMetrics(
        height: sizedBox.height!,
        consumesViewPadding: false,
      );
    }

    return estimate(sizedBox.child);
  }

  _NavigationBarMetrics? _fromConstrainedBox(ConstrainedBox constrainedBox) {
    final constraints = constrainedBox.constraints;
    if (constraints.hasTightHeight) {
      return _NavigationBarMetrics(
        height: constraints.maxHeight,
        consumesViewPadding: false,
      );
    }

    return estimate(constrainedBox.child);
  }
}

const double _kDefaultNavigationBarHeight = 88.0;

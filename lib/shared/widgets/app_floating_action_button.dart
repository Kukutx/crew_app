import 'package:flutter/material.dart';

enum AppFloatingActionButtonVariant { small, regular, extended }

class AppFloatingActionButtonAction {
  const AppFloatingActionButtonAction({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;
  final Object? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
}

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
    this.actions,
    this.expandedChild,
    this.variant = AppFloatingActionButtonVariant.small,
  })  : assert(
          variant != AppFloatingActionButtonVariant.small || child != null,
          'child is required for the small variant',
        ),
        assert(
          variant != AppFloatingActionButtonVariant.regular || child != null,
          'child is required for the regular variant',
        ),
        assert(
          variant != AppFloatingActionButtonVariant.extended || label != null,
          'label is required for the extended variant',
        ),
        assert(
          actions == null ||
              variant == AppFloatingActionButtonVariant.regular ||
              actions.isEmpty,
          'actions are only supported for the regular variant',
        );

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
  final List<AppFloatingActionButtonAction>? actions;
  final Widget? expandedChild;
  final AppFloatingActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? theme.colorScheme.onPrimary;
    final ShapeBorder defaultShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
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
        final actionList = actions;
        if (actionList != null && actionList.isNotEmpty) {
          button = _RegularAppFloatingActionButton(
            heroTag: heroTag,
            tooltip: tooltip,
            elevation: elevation,
            backgroundColor: effectiveBackgroundColor,
            foregroundColor: effectiveForegroundColor,
            shape: effectiveShape,
            child: child!,
            expandedChild: expandedChild,
            onPressed: onPressed,
            actions: actionList,
          );
        } else {
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
        }
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

class _RegularAppFloatingActionButton extends StatefulWidget {
  const _RegularAppFloatingActionButton({
    required this.onPressed,
    required this.child,
    required this.actions,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shape,
    this.expandedChild,
    this.heroTag,
    this.tooltip,
    this.elevation,
  });

  final VoidCallback onPressed;
  final Widget child;
  final List<AppFloatingActionButtonAction> actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final ShapeBorder shape;
  final Widget? expandedChild;
  final Object? heroTag;
  final String? tooltip;
  final double? elevation;

  @override
  State<_RegularAppFloatingActionButton> createState() =>
      _RegularAppFloatingActionButtonState();
}

class _RegularAppFloatingActionButtonState
    extends State<_RegularAppFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onPressed();
  }

  void _close() {
    if (!_open) {
      return;
    }
    setState(() {
      _open = false;
      _controller.reverse();
    });
  }

  void _handleActionPressed(AppFloatingActionButtonAction action) {
    action.onPressed();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = widget.actions;
    final animatedActions = <Widget>[];

    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      final animation = CurvedAnimation(
        parent: _controller,
        curve: Interval(
          i / actions.length,
          1,
          curve: Curves.easeOut,
        ),
      );
      final heroTag = action.heroTag ??
          (widget.heroTag != null ? '${widget.heroTag}_action_$i' : null);
      final labelTextStyle =
          theme.textTheme.bodyMedium ?? theme.textTheme.bodyLarge;
      animatedActions.add(
        _ExpandableAction(
          animation: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 4,
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: DefaultTextStyle(
                      style: (labelTextStyle ?? const TextStyle()).copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      child: action.label,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  heroTag: heroTag,
                  tooltip: action.tooltip,
                  elevation: widget.elevation,
                  backgroundColor:
                      action.backgroundColor ?? theme.colorScheme.secondary,
                  foregroundColor:
                      action.foregroundColor ?? theme.colorScheme.onSecondary,
                  shape: widget.shape,
                  onPressed: () => _handleActionPressed(action),
                  child: action.icon,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...animatedActions,
        FloatingActionButton(
          heroTag: widget.heroTag,
          tooltip: widget.tooltip,
          elevation: widget.elevation,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          shape: widget.shape,
          onPressed: () {
            if (widget.actions.isEmpty) {
              widget.onPressed();
            } else {
              _toggle();
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _open
                ? KeyedSubtree(
                    key: const ValueKey('expanded_fab_child'),
                    child: widget.expandedChild ?? const Icon(Icons.close),
                  )
                : KeyedSubtree(
                    key: const ValueKey('collapsed_fab_child'),
                    child: widget.child,
                  ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableAction extends StatelessWidget {
  const _ExpandableAction({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

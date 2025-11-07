import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crew_app/core/config/app_theme.dart';

/// Neumorphism 风格的按钮
class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.enableHapticFeedback = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool enableHapticFeedback;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  bool get _enabled => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.backgroundColor ?? colorScheme.surface;
    final effectiveForegroundColor = widget.foregroundColor ?? colorScheme.onSurface;
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);
    final effectivePadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              if (widget.enableHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: _enabled ? 1.0 : 0.6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: effectiveBorderRadius,
            gradient: AppTheme.neumorphicGradient(baseColor, isDark: isDark),
            boxShadow: _pressed || !_enabled
                ? AppTheme.neumorphicShadowPressed(colorScheme, isDark: isDark)
                : AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: effectiveForegroundColor.withValues(alpha: _enabled ? 0.92 : 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: effectiveForegroundColor.withValues(alpha: _enabled ? 0.92 : 0.5),
              ),
              child: Center(
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Neumorphism 风格的图标按钮
class NeumorphicIconButton extends StatefulWidget {
  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.enableHapticFeedback = true,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool enableHapticFeedback;

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.backgroundColor ?? colorScheme.surface;
    final effectiveForegroundColor = widget.foregroundColor ?? colorScheme.onSurface;

    Widget button = GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              if (widget.enableHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: _enabled ? 1.0 : 0.6,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.size / 3),
            gradient: AppTheme.neumorphicGradient(baseColor, isDark: isDark),
            boxShadow: _pressed || !_enabled
                ? AppTheme.neumorphicShadowPressed(colorScheme, isDark: isDark)
                : AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
          ),
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: widget.iconSize,
                color: effectiveForegroundColor.withValues(alpha: _enabled ? 0.92 : 0.5),
              ),
              child: widget.icon,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crew_app/core/config/app_theme.dart';

/// Neumorphism 风格的卡片组件
/// 
/// 支持凸起（raised）和凹陷（pressed）两种状态
class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    super.key,
    required this.child,
    this.pressed = false,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final bool pressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = colorScheme.surface;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);

    final decoration = BoxDecoration(
      color: baseColor,
      borderRadius: effectiveBorderRadius,
      gradient: gradient ?? AppTheme.neumorphicGradient(baseColor, isDark: isDark),
      boxShadow: pressed
          ? AppTheme.neumorphicShadowPressed(colorScheme, isDark: isDark)
          : AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
    );

    Widget result = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      result = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: result,
        ),
      );
    }

    return result;
  }
}

/// Neumorphism 风格的交互式卡片
/// 
/// 支持按下时的状态变化和触感反馈
class NeumorphicInteractiveCard extends StatefulWidget {
  const NeumorphicInteractiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.enableHapticFeedback = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableHapticFeedback;

  @override
  State<NeumorphicInteractiveCard> createState() => _NeumorphicInteractiveCardState();
}

class _NeumorphicInteractiveCardState extends State<NeumorphicInteractiveCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _pressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _pressed = false);
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) {
          setState(() => _pressed = false);
        }
      },
      child: NeumorphicCard(
        pressed: _pressed,
        padding: widget.padding,
        margin: widget.margin,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}

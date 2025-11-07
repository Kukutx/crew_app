import 'package:crew_app/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ToggleTabChanged = void Function(int index);

class ToggleTabBar extends StatelessWidget {
  const ToggleTabBar({
    super.key,
    required this.selectedIndex,
    required this.firstLabel,
    required this.secondLabel,
    required this.onChanged,
  });

  final int selectedIndex;
  final String firstLabel;
  final String secondLabel;
  final ToggleTabChanged onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surface,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleTabItem(
                label: firstLabel,
                selected: selectedIndex == 0,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(0);
                },
                isDark: isDark,
              ),
            ),
            Expanded(
              child: _ToggleTabItem(
                label: secondLabel,
                selected: selectedIndex == 1,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(1);
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTabItem extends StatelessWidget {
  const _ToggleTabItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(4),
      decoration: selected
          ? BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            )
          : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 2),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

typedef ToggleTabChanged = void Function(int index);

class ToggleTabBar extends StatelessWidget {
  const ToggleTabBar({
    super.key,
    required this.selectedIndex,
    required this.firstLabel,
    required this.secondLabel,
    required this.onChanged,
    this.firstIcon = Icons.favorite,
    this.secondIcon = Icons.autorenew,
    this.accessoryBuilder,
    this.leadingBuilder,
    this.trailingBuilder,
  });

  final int selectedIndex;
  final String firstLabel;
  final String secondLabel;
  final ToggleTabChanged onChanged;
  final IconData firstIcon;
  final IconData secondIcon;
  final Widget? Function(BuildContext context, int selectedIndex)?
      accessoryBuilder;
  final Widget? Function(BuildContext context, int selectedIndex)?
      leadingBuilder;
  final Widget? Function(BuildContext context, int selectedIndex)?
      trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final accessory = accessoryBuilder?.call(context, selectedIndex);
    final leading = leadingBuilder?.call(context, selectedIndex);
    final trailing = trailingBuilder?.call(context, selectedIndex);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (leading != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      leading,
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleTabChip(
                    label: firstLabel,
                    icon: firstIcon,
                    selected: selectedIndex == 0,
                    onTap: () => onChanged(0),
                  ),
                  const SizedBox(width: 12),
                  ToggleTabChip(
                    label: secondLabel,
                    icon: secondIcon,
                    selected: selectedIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                ],
              ),
              if (trailing != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      trailing,
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (accessory != null) ...[
          const SizedBox(height: 8),
          accessory,
        ],
      ],
    );
  }
}

class ToggleTabChip extends StatelessWidget {
  const ToggleTabChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = selected ? colorScheme.onPrimary : colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

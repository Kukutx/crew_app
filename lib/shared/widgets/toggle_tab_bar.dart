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
  leadingBuilder;
  final Widget? Function(BuildContext context, int selectedIndex)?
  trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final leading = leadingBuilder?.call(context, selectedIndex);
    final trailing = trailingBuilder?.call(context, selectedIndex);

    final tabs = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToggleTabChip(
          label: firstLabel,
          icon: firstIcon,
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 6),
        ToggleTabChip(
          label: secondLabel,
          icon: secondIcon,
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: leading!,
                ),
              Expanded(
                child: Center(child: tabs),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: trailing!,
                ),
            ],
          ),
        ),
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
    final foregroundColor = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

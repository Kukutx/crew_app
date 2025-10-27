import 'package:crew_app/shared/widgets/toggle_tab_chip.dart';
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 12),
            ],
            const Spacer(),
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
            const Spacer(),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ],
          ],
        ),
        if (accessory != null) ...[
          const SizedBox(height: 8),
          accessory,
        ],
      ],
    );
  }
}

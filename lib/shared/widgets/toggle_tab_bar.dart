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
  });

  final int selectedIndex;
  final String firstLabel;
  final String secondLabel;
  final ToggleTabChanged onChanged;
  final IconData firstIcon;
  final IconData secondIcon;
  final Widget? Function(BuildContext context, int selectedIndex)?
      accessoryBuilder;

  @override
  Widget build(BuildContext context) {
    final accessory = accessoryBuilder?.call(context, selectedIndex);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
        if (accessory != null) ...[
          const SizedBox(height: 8),
          accessory,
        ],
      ],
    );
  }
}

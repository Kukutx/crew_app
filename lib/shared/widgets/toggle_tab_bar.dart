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
  });

  final int selectedIndex;
  final String firstLabel;
  final String secondLabel;
  final ToggleTabChanged onChanged;
  final IconData firstIcon;
  final IconData secondIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

import 'package:flutter/material.dart';

import 'user_event_tab_chip.dart';

typedef UserEventsTabChanged = void Function(int index);

class UserEventsTabBar extends StatelessWidget {
  const UserEventsTabBar({
    super.key,
    required this.selectedIndex,
    required this.favoritesLabel,
    required this.registeredLabel,
    required this.onChanged,
  });

  final int selectedIndex;
  final String favoritesLabel;
  final String registeredLabel;
  final UserEventsTabChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UserEventTabChip(
          label: favoritesLabel,
          icon: Icons.favorite,
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        UserEventTabChip(
          label: registeredLabel,
          icon: Icons.autorenew,
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

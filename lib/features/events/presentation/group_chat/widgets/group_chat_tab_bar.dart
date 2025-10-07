import 'package:crew_app/features/events/presentation/group_chat/widgets/group_chat_tab_chip.dart';
import 'package:flutter/material.dart';

typedef GroupChatTabChanged = void Function(int index);

class GroupChatTabBar extends StatelessWidget {
  const GroupChatTabBar({
    super.key,
    required this.selectedIndex,
    required this.favoritesLabel,
    required this.registeredLabel,
    required this.onChanged,
  });

  final int selectedIndex;
  final String favoritesLabel;
  final String registeredLabel;
  final GroupChatTabChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GroupChatTabChip(
          label: favoritesLabel,
          icon: Icons.favorite,
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        GroupChatTabChip(
          label: registeredLabel,
          icon: Icons.autorenew,
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

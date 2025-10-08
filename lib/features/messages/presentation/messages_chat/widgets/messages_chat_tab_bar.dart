import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_tab_chip.dart';
import 'package:flutter/material.dart';

typedef MessagesChatTabChanged = void Function(int index);

class MessagesChatTabBar extends StatelessWidget {
  const MessagesChatTabBar({
    super.key,
    required this.selectedIndex,
    required this.favoritesLabel,
    required this.registeredLabel,
    required this.onChanged,
    this.favoritesIcon = Icons.favorite,
    this.registeredIcon = Icons.autorenew,
  });

  final int selectedIndex;
  final String favoritesLabel;
  final String registeredLabel;
  final MessagesChatTabChanged onChanged;
  final IconData favoritesIcon;
  final IconData registeredIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MessagesChatTabChip(
          label: favoritesLabel,
          icon: favoritesIcon,
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        MessagesChatTabChip(
          label: registeredLabel,
          icon: registeredIcon,
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

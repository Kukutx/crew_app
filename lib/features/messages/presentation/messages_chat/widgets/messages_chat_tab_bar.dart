import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_tab_chip.dart';
import 'package:flutter/material.dart';

typedef MessagesChatTabChanged = void Function(int index);

class MessagesChatTabBar extends StatelessWidget {
  const MessagesChatTabBar({
    super.key,
    required this.selectedIndex,
    required this.privateLabel,
    required this.groupLabel,
    required this.onChanged,
  });

  final int selectedIndex;
  final String privateLabel;
  final String groupLabel;
  final MessagesChatTabChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MessagesChatTabChip(
          label: privateLabel,
          icon: Icons.chat_bubble_outline,
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        MessagesChatTabChip(
          label: groupLabel,
          icon: Icons.groups_2_outlined,
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_tab_chip.dart';
import 'package:flutter/material.dart';

typedef MessagesChatTabChanged = void Function(int index);

class MessagesChatTabBar extends StatelessWidget {
  const MessagesChatTabBar({
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
  final MessagesChatTabChanged onChanged;
  final IconData firstIcon;
  final IconData secondIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MessagesChatTabChip(
          label: firstLabel,
          icon: firstIcon,
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 12),
        MessagesChatTabChip(
          label: secondLabel,
          icon: secondIcon,
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

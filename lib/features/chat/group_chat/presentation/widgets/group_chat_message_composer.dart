import 'package:flutter/material.dart';

class GroupChatMessageComposer extends StatelessWidget {
  const GroupChatMessageComposer({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'emoji',
                icon: Icon(Icons.emoji_emotions_outlined, color: colorScheme.primary),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'attach',
                icon: Icon(Icons.attach_file, color: colorScheme.primary),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: colorScheme.onPrimary),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

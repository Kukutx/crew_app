import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatRoomMessageComposer extends StatelessWidget {
  const ChatRoomMessageComposer({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSend,
    this.onEmojiTap,
    this.onMoreOptionsTap,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onMoreOptionsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    void showUnavailable(String label) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(loc.chat_action_unavailable(label)),
          ),
        );
    }

    VoidCallback withFallback(VoidCallback? callback, String label) {
      return callback ?? () => showUnavailable(label);
    }

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
                tooltip: loc.chat_composer_emoji_tooltip,
                icon: Icon(Icons.emoji_emotions_outlined, color: colorScheme.primary),
                onPressed:
                    withFallback(onEmojiTap, loc.chat_composer_emoji_tooltip),
              ),
              IconButton(
                tooltip: loc.chat_composer_more_tooltip,
                icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                onPressed:
                    withFallback(onMoreOptionsTap, loc.chat_composer_more_tooltip),
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
                  tooltip: loc.chat_composer_send_tooltip,
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

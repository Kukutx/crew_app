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
    this.onVoiceRecordStart,
    this.onVoiceRecordCancel,
    this.onVoiceRecordSend,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onMoreOptionsTap;
  final VoidCallback? onVoiceRecordStart;
  final VoidCallback? onVoiceRecordCancel;
  final VoidCallback? onVoiceRecordSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    final messenger = ScaffoldMessenger.of(context);

    void showUnavailable(String label) {
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

    Future<void> startVoiceRecording() async {
      onVoiceRecordStart?.call();

      final result = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: colorScheme.surface,
        showDragHandle: true,
        builder: (sheetContext) => _VoiceRecordingSheet(
          title: loc.chat_voice_recording_title,
          description: loc.chat_voice_recording_description,
          cancelLabel: loc.chat_voice_recording_cancel,
          sendLabel: loc.chat_voice_recording_send,
        ),
      );

      if (result == true) {
        onVoiceRecordSend?.call();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(loc.chat_voice_recording_sent_confirmation),
            ),
          );
      } else if (result == false) {
        onVoiceRecordCancel?.call();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(loc.chat_voice_recording_cancelled),
            ),
          );
      }
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
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: hasText
                        ? _SendMessageButton(
                            key: const ValueKey('send_button'),
                            colorScheme: colorScheme,
                            tooltip: loc.chat_composer_send_tooltip,
                            onPressed: onSend,
                          )
                        : _VoiceMessageButton(
                            key: const ValueKey('voice_button'),
                            colorScheme: colorScheme,
                            tooltip: loc.chat_composer_voice_tooltip,
                            onPressed: startVoiceRecording,
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendMessageButton extends StatelessWidget {
  const _SendMessageButton({
    super.key,
    required this.onPressed,
    required this.colorScheme,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.send_rounded, color: colorScheme.onPrimary),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _VoiceMessageButton extends StatelessWidget {
  const _VoiceMessageButton({
    super.key,
    required this.onPressed,
    required this.colorScheme,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.mic_rounded, color: colorScheme.onPrimary),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _VoiceRecordingSheet extends StatelessWidget {
  const _VoiceRecordingSheet({
    required this.title,
    required this.description,
    required this.cancelLabel,
    required this.sendLabel,
  });

  final String title;
  final String description;
  final String cancelLabel;
  final String sendLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_rounded, color: colorScheme.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(sendLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

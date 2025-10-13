import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatHeaderActions extends StatelessWidget {
  const ChatHeaderActions({
    super.key,
    required this.onOpenSettings,
    required this.onPhoneCallTap,
    required this.onVideoCallTap,
    this.onSearchTap,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onPhoneCallTap;
  final VoidCallback onVideoCallTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onSearchTap != null)
          IconButton(
            tooltip: loc.chat_search_hint,
            icon: const Icon(Icons.search),
            onPressed: onSearchTap,
          ),
        PopupMenuButton<_ChatHeaderAction>(
          tooltip: loc.chat_action_more_options,
          icon: const Icon(Icons.graphic_eq),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ChatHeaderAction.phoneCall,
              child: _HeaderActionRow(
                icon: Icons.call_outlined,
                label: loc.chat_action_phone_call,
              ),
            ),
            PopupMenuItem(
              value: _ChatHeaderAction.videoCall,
              child: _HeaderActionRow(
                icon: Icons.videocam_outlined,
                label: loc.chat_action_video_call,
              ),
            ),
          ],
          onSelected: (action) {
            switch (action) {
              case _ChatHeaderAction.phoneCall:
                onPhoneCallTap();
                break;
              case _ChatHeaderAction.videoCall:
                onVideoCallTap();
                break;
            }
          },
        ),
        IconButton(
          tooltip: loc.chat_action_open_settings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: onOpenSettings,
        ),
      ],
    );
  }
}

enum _ChatHeaderAction { phoneCall, videoCall }

class _HeaderActionRow extends StatelessWidget {
  const _HeaderActionRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

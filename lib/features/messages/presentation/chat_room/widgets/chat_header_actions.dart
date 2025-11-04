import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatHeaderActions extends StatelessWidget {
  const ChatHeaderActions({
    super.key,
    required this.onOpenSettings,
    this.onSearchTap,
  });

  final VoidCallback onOpenSettings;
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
        IconButton(
          tooltip: loc.chat_action_open_settings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: onOpenSettings,
        ),
      ],
    );
  }
}

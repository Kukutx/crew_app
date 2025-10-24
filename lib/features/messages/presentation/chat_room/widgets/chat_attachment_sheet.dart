import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class ChatAttachmentSheet extends StatelessWidget {
  const ChatAttachmentSheet({super.key, required this.onOptionSelected});

  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      _AttachmentOption(
        icon: Icons.attach_file,
        label: loc.chat_attachment_files,
        color: colorScheme.primary,
      ),
      _AttachmentOption(
        icon: Icons.photo_library_outlined,
        label: loc.chat_attachment_image,
        color: colorScheme.secondary,
      ),
      _AttachmentOption(
        icon: Icons.my_location_outlined,
        label: loc.chat_attachment_live_location,
        color: colorScheme.tertiary,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.chat_attachment_more,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CrewAvatar(
                    radius: 20,
                    backgroundColor: option.color.withValues(alpha: .12),
                    foregroundColor: option.color,
                    child: Icon(option.icon),
                  ),
                  title: Text(option.label),
                  onTap: () => onOptionSelected(option.label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption {
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

import 'package:flutter/material.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

enum MapQuickAction {
  quickTrip,
  fullTrip,
  moment,
}

Future<MapQuickAction?> showMapQuickActionsSheet(BuildContext context) {
  return showModalBottomSheet<MapQuickAction>(
    context: context,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final loc = AppLocalizations.of(sheetContext)!;
      final theme = Theme.of(sheetContext);
      final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      );

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.map_quick_actions_title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                loc.map_quick_actions_subtitle,
                style: subtitleStyle,
              ),
              const SizedBox(height: 20),
              _MapQuickActionTile(
                icon: Icons.bolt,
                iconBackgroundColor: theme.colorScheme.primaryContainer,
                iconColor: theme.colorScheme.onPrimaryContainer,
                title: loc.map_quick_actions_quick_trip,
                subtitle: loc.map_quick_actions_quick_trip_desc,
                onTap: () => Navigator.of(sheetContext).pop(MapQuickAction.quickTrip),
              ),
              const SizedBox(height: 12),
              _MapQuickActionTile(
                icon: Icons.route,
                iconBackgroundColor: theme.colorScheme.secondaryContainer,
                iconColor: theme.colorScheme.onSecondaryContainer,
                title: loc.map_quick_actions_full_trip,
                subtitle: loc.map_quick_actions_full_trip_desc,
                onTap: () => Navigator.of(sheetContext).pop(MapQuickAction.fullTrip),
              ),
              const SizedBox(height: 12),
              _MapQuickActionTile(
                icon: Icons.camera_alt_outlined,
                iconBackgroundColor: theme.colorScheme.tertiaryContainer,
                iconColor: theme.colorScheme.onTertiaryContainer,
                title: loc.map_quick_actions_moment,
                subtitle: loc.map_quick_actions_moment_desc,
                onTap: () => Navigator.of(sheetContext).pop(MapQuickAction.moment),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MapQuickActionTile extends StatelessWidget {
  const _MapQuickActionTile({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

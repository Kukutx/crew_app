import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MapQuickActionsContent extends StatelessWidget {
  const MapQuickActionsContent({
    super.key,
    required this.onStartQuickTrip,
    required this.onOpenFullTrip,
    required this.onCreateMoment,
    this.showTitle = true,
  });

  final VoidCallback onStartQuickTrip;
  final VoidCallback onOpenFullTrip;
  final VoidCallback onCreateMoment;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = <_QuickActionDefinition>[
      _QuickActionDefinition(
        icon: Icons.alt_route,
        title: loc.map_quick_actions_quick_trip,
        description: loc.map_quick_actions_quick_trip_desc,
        color: colorScheme.primary,
        onTap: onStartQuickTrip,
      ),
      _QuickActionDefinition(
        icon: Icons.edit_calendar_outlined,
        title: loc.map_quick_actions_full_trip,
        description: loc.map_quick_actions_full_trip_desc,
        color: colorScheme.secondary,
        onTap: onOpenFullTrip,
      ),
      _QuickActionDefinition(
        icon: Icons.photo_library_outlined,
        title: loc.map_quick_actions_create_moment,
        description: loc.map_quick_actions_create_moment_desc,
        color: colorScheme.tertiary,
        onTap: onCreateMoment,
      ),
    ];

    final tiles = <Widget>[
      if (showTitle) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            loc.map_quick_actions_title,
            style: theme.textTheme.titleLarge,
          ),
        ),
      ]
    ];

    tiles.add(
      Padding(
        padding: EdgeInsets.fromLTRB(20, showTitle ? 0 : 24, 20, 0),
        child: Text(
          loc.map_quick_actions_subtitle,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );

    tiles.add(const SizedBox(height: 16));

    for (var i = 0; i < actions.length; i++) {
      tiles.add(_MapQuickActionTile(definition: actions[i]));
      if (i != actions.length - 1) {
        tiles.add(const SizedBox(height: 12));
      }
    }

    tiles.add(const SizedBox(height: 24));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, showTitle ? 0 : 4, 20, 28),
      children: tiles,
    );
  }
}

class _QuickActionDefinition {
  const _QuickActionDefinition({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
}

class _MapQuickActionTile extends StatelessWidget {
  const _MapQuickActionTile({
    required this.definition,
  });

  final _QuickActionDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: definition.onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: definition.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(definition.icon, color: definition.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      definition.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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

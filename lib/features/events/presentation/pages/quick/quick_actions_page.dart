import 'package:crew_app/features/events/presentation/pages/map/state/map_quick_actions_provider.dart';
import 'package:crew_app/features/events/presentation/pages/trips/create_road_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

class MapQuickActionsPage extends ConsumerWidget {
  const MapQuickActionsPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigator = Navigator.of(context);

    void triggerAction(MapQuickAction action) {
      ref.read(mapQuickActionProvider.notifier).state = action;
    }

    final actions = <_QuickActionDefinition>[
      _QuickActionDefinition(
        icon: Icons.alt_route,
        title: loc.map_quick_actions_quick_trip,
        description: loc.map_quick_actions_quick_trip_desc,
        color: colorScheme.primary,
        onTap: () {
          triggerAction(MapQuickAction.startQuickTrip);
          onClose();
        },
      ),
      _QuickActionDefinition(
        icon: Icons.edit_calendar_outlined,
        title: loc.map_quick_actions_full_trip,
        description: loc.map_quick_actions_full_trip_desc,
        color: colorScheme.secondary,
        onTap: () {
          onClose();
          navigator.push(
            MaterialPageRoute(
              builder: (routeContext) => CreateRoadTripPage(
                onClose: () => Navigator.of(routeContext).maybePop(),
              ),
            ),
          );
        },
      ),
      _QuickActionDefinition(
        icon: Icons.photo_library_outlined,
        title: loc.map_quick_actions_create_moment,
        description: loc.map_quick_actions_create_moment_desc,
        color: colorScheme.tertiary,
        onTap: () {
          triggerAction(MapQuickAction.showMomentSheet);
          onClose();
        },
      ),
    ];

    Widget buildBody() {
      if (actions.isEmpty) {
        return _QuickActionsEmptyState(
          title: loc.map_quick_actions_empty_title,
          message: loc.map_quick_actions_empty_message,
        );
      }

      final tiles = <Widget>[
        Text(
          loc.map_quick_actions_subtitle,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
      ];

      for (var i = 0; i < actions.length; i++) {
        tiles.add(_MapQuickActionTile(definition: actions[i]));
        if (i != actions.length - 1) {
          tiles.add(const SizedBox(height: 12));
        }
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: tiles,
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.map_quick_actions_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ),
      body: SafeArea(
        child: buildBody(),
      ),
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
      elevation: 2,
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

class _QuickActionsEmptyState extends StatelessWidget {
  const _QuickActionsEmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upcoming_outlined,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

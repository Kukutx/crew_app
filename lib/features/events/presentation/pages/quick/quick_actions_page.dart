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

    final quickTripAction = _QuickActionDefinition(
      icon: Icons.alt_route,
      title: loc.map_quick_actions_quick_trip,
      description: loc.map_quick_actions_quick_trip_desc,
      color: colorScheme.primary,
      onTap: () {
        triggerAction(MapQuickAction.startQuickTrip);
        onClose();
      },
    );

    final actions = <_QuickActionDefinition>[
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
              title: Text(loc.map_quick_actions_title),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.map_quick_actions_subtitle,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    _QuickActionsHeroCard(
                      definition: quickTripAction,
                      buttonLabel: loc.action_create,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            if (actions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _QuickActionsEmptyState(
                    title: loc.map_quick_actions_empty_title,
                    message: loc.map_quick_actions_empty_message,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final definition = actions[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == actions.length - 1 ? 0 : 12,
                        ),
                        child: _MapQuickActionTile(definition: definition),
                      );
                    },
                    childCount: actions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsHeroCard extends StatelessWidget {
  const _QuickActionsHeroCard({
    required this.definition,
    required this.buttonLabel,
  });

  final _QuickActionDefinition definition;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            definition.color,
            definition.color.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: onPrimary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(definition.icon, size: 28, color: onPrimary),
            ),
            const SizedBox(height: 24),
            Text(
              definition.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              definition.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: onPrimary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                foregroundColor: definition.color,
                backgroundColor: colorScheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: definition.onTap,
              child: Text(
                buttonLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
                  color: definition.color.withOpacity(0.12),
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

import 'package:crew_app/features/events/presentation/pages/map/state/map_quick_actions_provider.dart';
import 'package:crew_app/features/events/presentation/pages/trips/create_road_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

class MapQuickActionsPage extends ConsumerStatefulWidget {
  const MapQuickActionsPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<MapQuickActionsPage> createState() =>
      _MapQuickActionsPageState();
}

class _MapQuickActionsPageState extends ConsumerState<MapQuickActionsPage> {
  @override
  Widget build(BuildContext context) {
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
          widget.onClose();
        },
      ),
      _QuickActionDefinition(
        icon: Icons.edit_calendar_outlined,
        title: loc.map_quick_actions_full_trip,
        description: loc.map_quick_actions_full_trip_desc,
        color: colorScheme.secondary,
        onTap: () {
          widget.onClose();
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
          widget.onClose();
        },
      ),
    ];

    final drawerRadius = const BorderRadius.only(
      topRight: Radius.circular(28),
      bottomRight: Radius.circular(28),
    );

    Widget buildBody() {
      if (actions.isEmpty) {
        return _QuickActionsEmptyState(
          title: loc.map_quick_actions_empty_title,
          message: loc.map_quick_actions_empty_message,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _MapQuickActionTile(
          definition: actions[index],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.32),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Material(
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(0.25),
                  borderRadius: drawerRadius,
                  color: colorScheme.surface,
                  child: ClipRRect(
                    borderRadius: drawerRadius,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 12, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.map_quick_actions_title,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      loc.map_quick_actions_subtitle,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                tooltip:
                                    MaterialLocalizations.of(context).closeButtonLabel,
                                onPressed: widget.onClose,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: actions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: buildBody(),
                                    ),
                                  )
                                : ScrollConfiguration(
                                    behavior: const ScrollBehavior()
                                        .copyWith(scrollbars: false),
                                    child: buildBody(),
                                  ),
                          ),
                        ),
                        const Divider(height: 1),
                        const SafeArea(
                          top: false,
                          child: SizedBox(height: 16),
                        ),
                      ],
                    ),
                  ),
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
    return Material(
      color: colorScheme.surfaceVariant.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: definition.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: definition.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  definition.icon,
                  color: definition.color,
                  size: 24,
                ),
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
                    const SizedBox(height: 4),
                    Text(
                      definition.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.upcoming_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
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
    );
  }
}

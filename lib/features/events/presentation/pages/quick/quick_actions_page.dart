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
      _QuickActionDefinition(
        icon: Icons.history,
        title: loc.map_quick_actions_history,
        description: loc.map_quick_actions_history_desc,
        color: colorScheme.outline,
        onTap: () {
          triggerAction(MapQuickAction.viewHistory);
          widget.onClose();
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Row(
              children: [
                _SidebarIconButton(onPressed: widget.onClose),
                const SizedBox(width: 12),
                Text(
                  loc.map_quick_actions_title,
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              loc.map_quick_actions_subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemBuilder: (context, index) =>
                  _MapQuickActionTile(definition: actions[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: actions.length,
            ),
          ),
          _QuickActionsBottomBar(
            shortcuts: [
              _QuickActionShortcut(
                icon: Icons.qr_code_scanner_outlined,
                label: loc.map_quick_actions_scan,
              ),
              _QuickActionShortcut(
                icon: Icons.support_agent_outlined,
                label: loc.map_quick_actions_support,
              ),
              _QuickActionShortcut(
                icon: Icons.settings_outlined,
                label: loc.map_quick_actions_settings,
              ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(child: buildBody()),
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
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: definition.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: definition.color.withOpacity(0.1),
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

class _SidebarIconButton extends StatelessWidget {
  const _SidebarIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.menu),
        ),
      ),
    );
  }
}

class _QuickActionsBottomBar extends StatelessWidget {
  const _QuickActionsBottomBar({required this.shortcuts});

  final List<_QuickActionShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final colorScheme = Theme.of(context).colorScheme;
    final children = <Widget>[];
    for (var i = 0; i < shortcuts.length; i++) {
      children.add(
        Expanded(
          child: _QuickActionShortcutButton(
            shortcut: shortcuts[i],
            color: colorScheme.surfaceVariant.withOpacity(0.5),
          ),
        ),
      );
      if (i != shortcuts.length - 1) {
        children.add(const SizedBox(width: 12));
      }
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

class _QuickActionShortcut {
  const _QuickActionShortcut({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _QuickActionShortcutButton extends StatelessWidget {
  const _QuickActionShortcutButton({
    required this.shortcut,
    required this.color,
  });

  final _QuickActionShortcut shortcut;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(shortcut.icon, color: colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                shortcut.label,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

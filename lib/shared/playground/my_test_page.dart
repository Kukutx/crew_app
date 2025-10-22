import 'package:flutter/material.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

class MyTestPage extends StatefulWidget {
  const MyTestPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<MyTestPage> createState() => _MyTestPageState();
}

class _MyTestPageState extends State<MyTestPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigator = Navigator.of(context);

    final actions = <_QuickActionDefinition>[
      _QuickActionDefinition(
        icon: Icons.auto_awesome_outlined,
        title: loc.map_quick_actions_my_moments,
        color: colorScheme.secondary,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/moments');
          });
        },
      ),
      _QuickActionDefinition(
        icon: Icons.drafts_outlined,
        title: loc.map_quick_actions_my_drafts,
        color: colorScheme.tertiary,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/drafts');
          });
        },
      ),
      _QuickActionDefinition(
        icon: Icons.person_add_alt_1_outlined,
        title: loc.map_quick_actions_add_friend,
        color: colorScheme.primary,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/add_friend');
          });
        },
      ),
      _QuickActionDefinition(
        icon: Icons.account_balance_wallet_outlined,
        title: loc.map_quick_actions_wallet,
        color: colorScheme.secondary,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/wallet');
          });
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
        primary: false,
        shrinkWrap: true,
        children: tiles,
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.map_quick_actions_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: buildBody(),
    );
  }
}

class _QuickActionDefinition {
  const _QuickActionDefinition({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Text(
                  definition.title,
                  style: theme.textTheme.titleMedium,
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

import 'package:flutter/material.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

class MapQuickActionsDrawer extends StatefulWidget {
  const MapQuickActionsDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<MapQuickActionsDrawer> createState() => _MapQuickActionsDrawerState();
}

class _MapQuickActionsDrawerState extends State<MapQuickActionsDrawer> {
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

    final bottomActions = <_BottomActionDefinition>[
      _BottomActionDefinition(
        icon: Icons.qr_code_scanner_outlined,
        label: loc.map_quick_actions_bottom_scan,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/qr-scanner');
          });
        },
      ),
      _BottomActionDefinition(
        icon: Icons.support_agent_outlined,
        label: loc.map_quick_actions_bottom_support,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/support');
          });
        },
      ),
      _BottomActionDefinition(
        icon: Icons.settings_outlined,
        label: loc.map_quick_actions_bottom_settings,
        onTap: () {
          widget.onClose();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigator.pushNamed('/settings');
          });
        },
      ),
    ];

    final drawerBackground = theme.colorScheme.surface;
    return Drawer(
      backgroundColor: drawerBackground,
      child: Column(
        children: [
            if (actions.isEmpty)
              Expanded(
                child: _QuickActionsEmptyState(
                  title: loc.map_quick_actions_empty_title,
                  message: loc.map_quick_actions_empty_message,
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  itemBuilder: (context, index) =>
                      _MapQuickActionTile(definition: actions[index]),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemCount: actions.length,
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < bottomActions.length; i++) ...[
                    Expanded(
                      child: _DrawerBottomAction(
                        definition: bottomActions[i],
                      ),
                    ),
                    if (i != bottomActions.length - 1)
                      const SizedBox(width: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
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

class _BottomActionDefinition {
  const _BottomActionDefinition({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
    final borderColor = colorScheme.outlineVariant;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: definition.onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: definition.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(definition.icon, color: definition.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  definition.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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

class _DrawerBottomAction extends StatelessWidget {
  const _DrawerBottomAction({required this.definition});

  final _BottomActionDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: definition.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                definition.icon,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              definition.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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

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

    final featuredAction = _QuickActionDefinition(
      icon: Icons.person_add_alt_1_outlined,
      title: loc.map_quick_actions_add_friend,
      subtitle: loc.map_quick_actions_add_friend_subtitle,
      color: colorScheme.primary,
      onTap: () {
        widget.onClose();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigator.pushNamed('/add_friend');
        });
      },
    );

    final actionGroups = <_QuickActionGroup>[
      _QuickActionGroup(
        label: loc.map_quick_actions_section_personal,
        actions: [
          _QuickActionDefinition(
            icon: Icons.event_available_outlined,
            title: loc.map_quick_actions_my_activities,
            subtitle: loc.map_quick_actions_my_activities_subtitle,
            color: colorScheme.primary,
            onTap: () {
              widget.onClose();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigator.pushNamed('/my_activities');
              });
            },
          ),
          _QuickActionDefinition(
            icon: Icons.auto_awesome_outlined,
            title: loc.map_quick_actions_my_moments,
            subtitle: loc.map_quick_actions_my_moments_subtitle,
            color: colorScheme.secondary,
            onTap: () {
              widget.onClose();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigator.pushNamed('/moments');
              });
            },
          ),
          _QuickActionDefinition(
            icon: Icons.receipt_long_outlined,
            title: loc.map_quick_actions_my_ledger,
            subtitle: loc.map_quick_actions_my_ledger_subtitle,
            color: colorScheme.tertiary,
            onTap: () {
              widget.onClose();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigator.pushNamed('/expenses');
              });
            },
          ),
          _QuickActionDefinition(
            icon: Icons.account_balance_wallet_outlined,
            title: loc.map_quick_actions_wallet,
            subtitle: loc.map_quick_actions_wallet_subtitle,
            color: colorScheme.secondary,
            onTap: () {
              widget.onClose();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigator.pushNamed('/wallet');
              });
            },
          ),
        ],
      ),
      _QuickActionGroup(
        label: loc.map_quick_actions_section_workspace,
        actions: [
          _QuickActionDefinition(
            icon: Icons.drafts_outlined,
            title: loc.map_quick_actions_my_drafts,
            subtitle: loc.map_quick_actions_my_drafts_subtitle,
            color: colorScheme.secondary,
            onTap: () {
              widget.onClose();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigator.pushNamed('/drafts');
              });
            },
          ),
        ],
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
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: actionGroups.expand((group) => group.actions).isEmpty
                  ? _QuickActionsEmptyState(
                      title: loc.map_quick_actions_empty_title,
                      message: loc.map_quick_actions_empty_message,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.map_quick_actions_section_connect,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FeaturedQuickActionCard(definition: featuredAction),
                          const SizedBox(height: 28),
                          for (final group in actionGroups) ...[
                            _QuickActionSection(group: group),
                            const SizedBox(height: 28),
                          ],
                        ],
                      ),
                    ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;
}

class _QuickActionGroup {
  const _QuickActionGroup({required this.label, required this.actions});

  final String label;
  final List<_QuickActionDefinition> actions;
}

class _FeaturedQuickActionCard extends StatelessWidget {
  const _FeaturedQuickActionCard({required this.definition});

  final _QuickActionDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: definition.onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                definition.color.withOpacity(0.18),
                colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: definition.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  definition.icon,
                  color: definition.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      definition.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (definition.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        definition.subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection({required this.group});

  final _QuickActionGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: [
            for (var i = 0; i < group.actions.length; i++) ...[
              _MapQuickActionTile(definition: group.actions[i]),
              if (i != group.actions.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
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
    final borderColor = colorScheme.outlineVariant.withOpacity(0.35);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: definition.onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                definition.color.withOpacity(0.10),
                colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: definition.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(definition.icon, color: definition.color, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      definition.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (definition.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        definition.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
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

import 'package:flutter/material.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigator = Navigator.of(context);

    final menuGroups = <_AppMenuGroup>[
      _AppMenuGroup(
        actions: [
          _AppMenuItemDefinition(
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
        ],
      ),
      _AppMenuGroup(
        actions: [
          _AppMenuItemDefinition(
            icon: Icons.event_available_outlined,
            title: loc.map_quick_actions_my_event,
            color: colorScheme.primary,
            onTap: () {
              widget.onClose();
            },
          ),
          _AppMenuItemDefinition(
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
          _AppMenuItemDefinition(
            icon: Icons.receipt_long_outlined,
            title: loc.map_quick_actions_my_ledger,
            color: colorScheme.tertiary,
            onTap: () {
              widget.onClose();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigator.pushNamed('/expenses');
              });
            },
          ),
          _AppMenuItemDefinition(
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
        ],
      ),
      _AppMenuGroup(
        actions: [
          _AppMenuItemDefinition(
            icon: Icons.drafts_outlined,
            title: loc.map_quick_actions_my_drafts,
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
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final group in menuGroups) ...[
                      _AppMenuItemSection(group: group),
                      const SizedBox(height: 28),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 1),
          Builder(
            builder: (context) {
              // iOS 底部 Home 指示条、Android 手势导航等的安全距离
              final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
              return Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomSafe),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppMenuItemDefinition {
  const _AppMenuItemDefinition({
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

class _AppMenuGroup {
  const _AppMenuGroup({required this.actions});

  final List<_AppMenuItemDefinition> actions;
}

class _AppMenuItemSection extends StatelessWidget {
  const _AppMenuItemSection({required this.group});
  final _AppMenuGroup group;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < group.actions.length; i++) ...[
            _MinimalTile(definition: group.actions[i]),
            if (i != group.actions.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
          ],
        ],
      ),
    );
  }
}

class _MinimalTile extends StatelessWidget {
  const _MinimalTile({required this.definition});
  final _AppMenuItemDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: definition.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(definition.icon, size: 22, color: cs.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                definition.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
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
              child: Icon(definition.icon, color: colorScheme.onSurfaceVariant),
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

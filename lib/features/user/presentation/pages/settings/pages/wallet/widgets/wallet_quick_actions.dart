import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class WalletQuickActions extends StatelessWidget {
  const WalletQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.wallet_quick_actions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _WalletQuickAction(
                icon: Icons.savings_outlined,
                label: loc.wallet_action_top_up,
                color: colorScheme.primary,
                background: colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WalletQuickAction(
                icon: Icons.wallet_outlined,
                label: loc.wallet_action_withdraw,
                color: colorScheme.secondary,
                background: colorScheme.secondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WalletQuickAction(
                icon: Icons.swap_horiz_outlined,
                label: loc.wallet_action_transfer,
                color: colorScheme.tertiary,
                background: colorScheme.tertiaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WalletQuickAction extends StatelessWidget {
  const _WalletQuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: background.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrewAvatar(
              radius: 22,
              backgroundColor: background,
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

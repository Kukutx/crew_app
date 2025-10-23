import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: .65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: .35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.wallet_balance_label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: .9),
                ),
              ),
              _LastUpdatedChip(label: loc.wallet_last_updated('5m')),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '¥ 2,860.00',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: const [
              Expanded(
                child: _WalletInfoChip(
                  labelKey: _WalletInfoLabel.reserved,
                  value: '¥ 320',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _WalletInfoChip(
                  labelKey: _WalletInfoLabel.reward,
                  value: '2,450',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletInfoChip extends StatelessWidget {
  const _WalletInfoChip({
    required this.labelKey,
    required this.value,
  });

  final _WalletInfoLabel labelKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final label = switch (labelKey) {
      _WalletInfoLabel.reserved => loc.wallet_reserved_funds,
      _WalletInfoLabel.reward => loc.wallet_reward_points,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: .85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

enum _WalletInfoLabel { reserved, reward }

class _LastUpdatedChip extends StatelessWidget {
  const _LastUpdatedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            size: 16,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

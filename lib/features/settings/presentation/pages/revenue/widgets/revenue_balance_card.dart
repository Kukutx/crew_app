import 'package:crew_app/core/config/app_theme.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/wallet_balance.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:flutter/material.dart';

/// 收益余额卡片
/// 
/// 显示可用余额和预留资金
class RevenueBalanceCard extends StatelessWidget {
  const RevenueBalanceCard({
    required this.balance,
    super.key,
  });

  final WalletBalance balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final baseColor = colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        gradient: AppTheme.neumorphicGradient(baseColor, isDark: isDark),
        boxShadow: AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
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
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (balance.lastUpdated != null)
                _LastUpdatedChip(
                  label: loc.wallet_last_updated(
                    _formatTimeAgo(balance.lastUpdated!),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            NumberFormatHelper.formatCurrency(balance.availableBalance),
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _BalanceInfoChip(
                  label: loc.wallet_reserved_funds,
                  value: NumberFormatHelper.formatCurrency(balance.reservedBalance),
                  tooltip: loc.wallet_reserved_funds_tooltip,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时';
    } else {
      return '${difference.inDays}天';
    }
  }
}

class _BalanceInfoChip extends StatelessWidget {
  const _BalanceInfoChip({
    required this.label,
    required this.value,
    this.tooltip,
  });

  final String label;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: .85),
                  fontSize: 13,
                ),
              ),
              if (tooltip != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip!,
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );

    return chip;
  }
}

class _LastUpdatedChip extends StatelessWidget {
  const _LastUpdatedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            size: 16,
            color: colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}


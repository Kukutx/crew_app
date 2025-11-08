import 'package:crew_app/core/config/app_theme.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/revenue_transaction.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

/// 交易记录卡片
class RevenueTransactionsCard extends StatelessWidget {
  const RevenueTransactionsCard({
    required this.transactions,
    super.key,
  });

  final List<RevenueTransaction> transactions;

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.wallet_recent_activity,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  loc.wallet_activity_empty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _TransactionItem(transaction: transaction);
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
              itemCount: transactions.length,
            ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final RevenueTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = transaction.getIconColor(colorScheme);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CrewAvatar(
        radius: 24,
        backgroundColor: iconColor.withValues(alpha: .12),
        foregroundColor: iconColor,
        child: Icon(transaction.icon),
      ),
      title: Text(
        transaction.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        transaction.subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        transaction.isIncome
            ? '+${NumberFormatHelper.formatCurrency(transaction.amount)}'
            : '−${NumberFormatHelper.formatCurrency(-transaction.amount)}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: transaction.isIncome
              ? colorScheme.primary
              : colorScheme.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}


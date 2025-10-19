import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    final transactions = _sampleTransactions(loc, colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.wallet_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.wallet_insights_title,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.wallet_help_description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(loc.wallet_help_close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WalletBalanceCard(colorScheme: colorScheme, theme: theme, loc: loc),
            const SizedBox(height: 28),
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
            const SizedBox(height: 28),
            _WalletInsightsCard(theme: theme, colorScheme: colorScheme, loc: loc),
            const SizedBox(height: 28),
            _WalletManagementCard(theme: theme, loc: loc),
            const SizedBox(height: 28),
            _WalletTransactionsCard(transactions: transactions, theme: theme, loc: loc),
          ],
        ),
      ),
    );
  }

  List<_WalletTransaction> _sampleTransactions(
    AppLocalizations loc,
    ColorScheme colorScheme,
  ) {
    return [
      _WalletTransaction(
        icon: Icons.emoji_events_outlined,
        iconColor: colorScheme.primary,
        title: loc.wallet_transaction_payout_title,
        subtitle: loc.wallet_transaction_payout_subtitle,
        amount: '+¥352.00',
      ),
      _WalletTransaction(
        icon: Icons.refresh_outlined,
        iconColor: colorScheme.tertiary,
        title: loc.wallet_transaction_refund_title,
        subtitle: loc.wallet_transaction_refund_subtitle,
        amount: '+¥68.00',
      ),
      _WalletTransaction(
        icon: Icons.auto_awesome_outlined,
        iconColor: colorScheme.secondary,
        title: loc.wallet_transaction_subscription_title,
        subtitle: loc.wallet_transaction_subscription_subtitle,
        amount: '−¥38.00',
      ),
    ];
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.colorScheme,
    required this.theme,
    required this.loc,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
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
                  color: colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.wallet_last_updated('5m'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
            children: [
              Expanded(
                child: _WalletInfoChip(
                  label: loc.wallet_reserved_funds,
                  value: '¥ 320',
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _WalletInfoChip(
                  label: loc.wallet_reward_points,
                  value: '2,450',
                  colorScheme: colorScheme,
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
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.85),
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
          color: background.withOpacity(0.55),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: background,
              child: Icon(icon, color: color),
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

class _WalletInsightsCard extends StatelessWidget {
  const _WalletInsightsCard({
    required this.theme,
    required this.colorScheme,
    required this.loc,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: colorScheme.surfaceVariant.withOpacity(0.55),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.wallet_insights_title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.wallet_insights_description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InsightTile(
                    label: loc.wallet_insight_income,
                    value: '¥ 1,280',
                    trend: '+18%',
                    trendPositive: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InsightTile(
                    label: loc.wallet_insight_expense,
                    value: '¥ 268',
                    trend: '−5%',
                    trendPositive: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendPositive,
  });

  final String label;
  final String value;
  final String trend;
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                trendPositive ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: trendPositive
                    ? colorScheme.primary
                    : colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: trendPositive
                      ? colorScheme.primary
                      : colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletManagementCard extends StatelessWidget {
  const _WalletManagementCard({
    required this.theme,
    required this.loc,
  });

  final ThemeData theme;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(loc.wallet_view_statements),
              subtitle: Text(loc.wallet_view_statements_subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.feature_not_ready)),
                );
              },
            ),
            const Divider(height: 8),
            ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: Text(loc.wallet_manage_methods),
              subtitle: Text(loc.wallet_manage_methods_subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.feature_not_ready)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTransactionsCard extends StatelessWidget {
  const _WalletTransactionsCard({
    required this.transactions,
    required this.theme,
    required this.loc,
  });

  final List<_WalletTransaction> transactions;
  final ThemeData theme;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                loc.wallet_recent_activity,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Text(
                  loc.wallet_activity_empty,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: transaction.iconColor.withOpacity(0.12),
                      child: Icon(
                        transaction.icon,
                        color: transaction.iconColor,
                      ),
                    ),
                    title: Text(transaction.title),
                    subtitle: Text(transaction.subtitle),
                    trailing: Text(
                      transaction.amount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: transaction.amount.startsWith('−')
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  indent: 20,
                  endIndent: 20,
                  color: theme.dividerColor.withOpacity(0.08),
                ),
                itemCount: transactions.length,
              ),
          ],
        ),
      ),
    );
  }
}

class _WalletTransaction {
  const _WalletTransaction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
}

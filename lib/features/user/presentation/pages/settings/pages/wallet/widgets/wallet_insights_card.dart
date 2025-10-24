import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletInsightsCard extends StatelessWidget {
  const WalletInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: .55),
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
              children: const [
                Expanded(
                  child: _InsightTile(
                    labelType: _InsightType.income,
                    value: '¥ 1,280',
                    trend: '+18%',
                    trendPositive: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _InsightTile(
                    labelType: _InsightType.expense,
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
    required this.labelType,
    required this.value,
    required this.trend,
    required this.trendPositive,
  });

  final _InsightType labelType;
  final String value;
  final String trend;
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    final label = switch (labelType) {
      _InsightType.income => loc.wallet_insight_income,
      _InsightType.expense => loc.wallet_insight_expense,
    };

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

enum _InsightType { income, expense }

import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/features/expenses/widgets/avatar.dart';
import 'package:crew_app/features/expenses/widgets/expense_list_tile.dart';
import 'package:crew_app/features/expenses/widgets/summary_row.dart';
import 'package:flutter/material.dart';

class MemberDetailsSheet extends StatelessWidget {
  const MemberDetailsSheet({
    super.key,
    required this.participant,
    required this.difference,
    required this.scrollController,
  });

  final Participant participant;
  final double difference;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final currency = NumberFormatHelper.currency;
    final dragHandleColor = colorScheme.outlineVariant
        .withValues(alpha: isDark ? 0.6 : 0.35);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final highlightScheme = ColorScheme.fromSeed(
      seedColor: difference >= 0
          ? colorScheme.tertiary
          : colorScheme.error,
      brightness: colorScheme.brightness,
    );
    final summaryBackground = Color.alphaBlend(
      highlightScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
      colorScheme.surfaceContainerHighest,
    );
    final summaryBorderColor = highlightScheme.outlineVariant;
    final summaryAccentColor = highlightScheme.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: dragHandleColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Avatar(name: participant.name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${currency.format(participant.total)} · ${participant.expenses.length} 笔消费',
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: participant.expenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final expense = participant.expenses[index];
                return ExpenseListTile(expense: expense);
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: summaryBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: summaryBorderColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryRow(
                  label: '总计',
                  value: currency.format(participant.total),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  label: '平摊后差额',
                  value: difference >= 0
                      ? '+${currency.format(difference.abs())}'
                      : '-${currency.format(difference.abs())}',
                  valueColor: summaryAccentColor,
                ),
                const SizedBox(height: 8),
                Text(
                  difference >= 0
                      ? '需要收回 ${currency.format(difference.abs())}'
                      : '仍需补交 ${currency.format(difference.abs())}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: summaryAccentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

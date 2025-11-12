import 'package:crew_app/features/expenses/data/member.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:crew_app/features/expenses/widgets/expense_list_tile.dart';
import 'package:crew_app/features/expenses/widgets/summary_row.dart';
import 'package:flutter/material.dart';

class MemberDetailsSheet extends StatelessWidget {
  const MemberDetailsSheet({
    super.key,
    required this.member,
    required this.difference,
    required this.allMembers,
    required this.scrollController,
  });

  final Member member;
  final double difference;
  final List<Member> allMembers;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final dragHandleColor = isDark ? Colors.white24 : Colors.grey.shade300;
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isDark ? colorScheme.onSurfaceVariant : Colors.black54,
    );
    const positiveAccent = Color(0xFF1B8A5C);
    final summaryBackground = isDark
        ? Color.alphaBlend(
            positiveAccent.withValues(alpha: 0.2),
            colorScheme.surface,
          )
        : const Color(0xFFE8F8F0);
    final summaryBorderColor = positiveAccent.withValues(
      alpha: isDark ? 0.3 : 0.2,
    );
    final summaryAccentColor = difference >= 0
        ? positiveAccent
        : Colors.redAccent;
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
              CrewAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1B8A5C),
                foregroundColor: Colors.white,
                child: Text(
                  member.name.isEmpty
                      ? ''
                      : member.name.trim().split(RegExp(r'\s+')).map((part) => part[0]).take(2).join(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${NumberFormatHelper.formatCurrencyCompact(member.totalPaid)} · ${member.expenses.length} 笔消费',
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
              itemCount: member.expenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final expense = member.expenses[index];
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
              border: Border.all(
                color: summaryBorderColor.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryRow(
                  label: '总计支付',
                  value: NumberFormatHelper.formatCurrencyCompact(
                    member.totalPaid,
                  ),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  label: '应承担',
                  value: NumberFormatHelper.formatCurrencyCompact(
                    member.totalOwed(allMembers),
                  ),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  label: '平摊后差额',
                  value: difference >= 0
                      ? '+${NumberFormatHelper.formatCurrencyCompact(difference.abs())}'
                      : '-${NumberFormatHelper.formatCurrencyCompact(difference.abs())}',
                  valueColor: summaryAccentColor,
                ),
                const SizedBox(height: 8),
                Text(
                  difference >= 0
                      ? '需要收回 ${NumberFormatHelper.formatCurrencyCompact(difference.abs())}'
                      : '仍需补交 ${NumberFormatHelper.formatCurrencyCompact(difference.abs())}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

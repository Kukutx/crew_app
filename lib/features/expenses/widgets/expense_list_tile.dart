import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/shared/utils/formatted_date.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:flutter/material.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({super.key, required this.expense});

  final ParticipantExpense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final currency = NumberFormatHelper.currency;
    final cardColor = isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.04),
            colorScheme.surface,
          )
        : Colors.white;
    const categoryColor = Color(0xFF1B8A5C);
    final categoryBackground = isDark
        ? categoryColor.withValues(alpha: 0.24)
        : categoryColor.withValues(alpha: 0.12);
    final categoryForeground = isDark ? Colors.white : categoryColor;
    final supportingTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: isDark ? colorScheme.onSurfaceVariant : Colors.black54,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense.category,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: categoryForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                currency.format(expense.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(expense.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            FormattedDate.relative(expense.timestamp),
            style: supportingTextStyle,
          ),
          if (expense.paymentMethod != null || expense.note != null) ...[
            const SizedBox(height: 12),
            if (expense.paymentMethod != null)
              Text('支付方式：${expense.paymentMethod}', style: supportingTextStyle),
            if (expense.note != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  expense.note!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

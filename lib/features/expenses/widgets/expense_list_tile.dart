import 'package:crew_app/features/expenses/models/participant.dart';
import 'package:crew_app/features/expenses/utils/formatted_date.dart';
import 'package:crew_app/features/expenses/utils/number_format_helper.dart';
import 'package:flutter/material.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    super.key,
    required this.expense,
  });

  final ParticipantExpense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormatHelper.currency;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8A5C).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense.category,
                  style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF1B8A5C),
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
          Text(
            expense.title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            FormattedDate.relative(expense.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          if (expense.paymentMethod != null || expense.note != null) ...[
            const SizedBox(height: 12),
            if (expense.paymentMethod != null)
              Text(
                '支付方式：${expense.paymentMethod}',
                style: theme.textTheme.bodySmall,
              ),
            if (expense.note != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  expense.note!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

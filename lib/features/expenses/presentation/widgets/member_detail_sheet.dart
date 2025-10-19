import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../application/settlement_calculator.dart';
import '../../data/models/expense.dart';

class MemberDetailSheet extends StatelessWidget {
  MemberDetailSheet({
    super.key,
    required this.member,
    required this.members,
    required this.expenses,
    required this.onDeleteExpense,
  }) : _calculator = const SettlementCalculator();

  final Member member;
  final Map<String, Member> members;
  final List<Expense> expenses;
  final ValueChanged<Expense> onDeleteExpense;
  final SettlementCalculator _calculator;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '€');
    final items = expenses
        .map((expense) => (expense: expense, amount: _calculator.shareAmountFor(expense, member.id)))
        .where((entry) => entry.amount > 0)
        .toList()
      ..sort((a, b) => b.expense.createdAt.compareTo(a.expense.createdAt));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${member.name} 的消费',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '总计 ${formatter.format(member.total)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          '暂无消费记录',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        controller: controller,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final payer = members[item.expense.payerId]?.name ?? '未知成员';
                          return ListTile(
                            title: Text(item.expense.title),
                            subtitle: Text('支付者：$payer'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(formatter.format(item.amount)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('删除消费'),
                                          content: Text('确定要删除“${item.expense.title}”吗？'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('取消'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('删除'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmed == true) {
                                      onDeleteExpense(item.expense);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemCount: items.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

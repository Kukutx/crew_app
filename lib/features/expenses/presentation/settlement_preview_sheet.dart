import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/expense.dart';

class SettlementPreviewSheet extends StatelessWidget {
  SettlementPreviewSheet({
    super.key,
    required this.settlement,
    required this.members,
  }) : _formatter = NumberFormat.currency(symbol: '€');

  final Settlement settlement;
  final Map<String, Member> members;
  final NumberFormat _formatter;

  @override
  Widget build(BuildContext context) {
    final totalTransfers = settlement.transfers.fold<double>(
      0,
      (sum, transfer) => sum + transfer.amount,
    );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, controller) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '结算预览',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '最小转账笔数：${settlement.transfers.length} 笔，总额 ${_formatter.format(totalTransfers)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: settlement.transfers.length,
                  itemBuilder: (context, index) {
                    final transfer = settlement.transfers[index];
                    final from = members[transfer.fromMemberId]?.name ?? transfer.fromMemberId;
                    final to = members[transfer.toMemberId]?.name ?? transfer.toMemberId;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('$from → $to'),
                      subtitle: Text('金额 ${_formatter.format(transfer.amount)}'),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('成员结余：', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: settlement.balances.entries
                          .map(
                            (entry) => Chip(
                              label: Text(
                                '${members[entry.key]?.name ?? entry.key}: ${_formatter.format(entry.value)}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

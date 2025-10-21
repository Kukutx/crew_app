import 'package:crew_app/features/expenses/models/participant.dart';
import 'package:crew_app/features/expenses/utils/number_format_helper.dart';
import 'package:crew_app/features/expenses/widgets/avatar.dart';
import 'package:flutter/material.dart';

class SettlementPreviewSheet extends StatelessWidget {
  const SettlementPreviewSheet({
    super.key,
    required this.entries,
  });

  final List<SettlementEntry> entries;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormatHelper.currency;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '结算预览',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final color = entry.difference >= 0
                    ? const Color(0xFF1B8A5C)
                    : Colors.redAccent;
                return ListTile(
                  leading: Avatar(name: entry.participant.name),
                  title: Text(entry.participant.name),
                  subtitle: Text(
                    entry.difference >= 0
                        ? '应收 ${currency.format(entry.difference.abs())}'
                        : '需补 ${currency.format(entry.difference.abs())}',
                  ),
                  trailing: Text(
                    '${entry.difference >= 0 ? '+' : '-'}${currency.format(entry.difference.abs())}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: entries.map((entry) {
              final isPositive = entry.difference >= 0;
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor:
                      isPositive ? const Color(0xFF1B8A5C) : Colors.redAccent,
                  child: Icon(
                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFFE8F8F0),
                label: Text(
                  '${entry.participant.name} ${isPositive ? '收回' : '补给'} ${currency.format(entry.difference.abs())}',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SettlementEntry {
  const SettlementEntry({
    required this.participant,
    required this.difference,
  });

  final Participant participant;
  final double difference;
}

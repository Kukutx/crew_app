import 'package:crew_app/features/expenses/data/member.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class SettlementPreviewSheet extends StatelessWidget {
  const SettlementPreviewSheet({
    super.key,
    required this.entries,
  });

  final List<SettlementEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final dragHandleColor = colorScheme.outlineVariant
        .withValues(alpha: isDark ? 0.5 : 0.35);
    final positiveScheme = ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: colorScheme.brightness,
    );
    final negativeScheme = ColorScheme.fromSeed(
      seedColor: colorScheme.error,
      brightness: colorScheme.brightness,
    );
    final positiveColor = positiveScheme.primary;
    final negativeColor = negativeScheme.primary;
    final positiveContainer = positiveScheme.primaryContainer;
    final negativeContainer = negativeScheme.primaryContainer;
    final positiveOnColor = positiveScheme.onPrimary;
    final negativeOnColor = negativeScheme.onPrimary;
    final positiveOnContainer = positiveScheme.onPrimaryContainer;
    final negativeOnContainer = negativeScheme.onPrimaryContainer;
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
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
                color: dragHandleColor,
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
                final isPositive = entry.difference >= 0;
                final accentColor = isPositive ? positiveColor : negativeColor;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    tileColor: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: CrewAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF1B8A5C),
                      foregroundColor: Colors.white,
                      child: Text(
                        entry.member.name.isEmpty
                            ? ''
                            : entry.member.name.trim().split(RegExp(r'\s+')).map((part) => part[0]).take(2).join(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(entry.member.name),
                    subtitle: Text(
                      isPositive
                          ? '应收 ${NumberFormatHelper.formatCurrencyCompact(entry.difference.abs())}'
                          : '需补 ${NumberFormatHelper.formatCurrencyCompact(entry.difference.abs())}',
                      style: subtitleStyle,
                    ),
                    trailing: Text(
                      '${isPositive ? '+' : '-'}${NumberFormatHelper.formatCurrencyCompact(entry.difference.abs())}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
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
              final accentColor = isPositive ? positiveColor : negativeColor;
              final onAccentColor =
                  isPositive ? positiveOnColor : negativeOnColor;
              final containerColor =
                  isPositive ? positiveContainer : negativeContainer;
              final onContainerColor = isPositive
                  ? positiveOnContainer
                  : negativeOnContainer;
              return Chip(
                avatar: CrewAvatar(
                  radius: 16,
                  backgroundColor: accentColor,
                  foregroundColor: onAccentColor,
                  child: Icon(
                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 16,
                  ),
                ),
                backgroundColor: containerColor,
                label: Text(
                  '${entry.member.name} ${isPositive ? '收回' : '补给'} ${NumberFormatHelper.formatCurrencyCompact(entry.difference.abs())}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onContainerColor,
                  ),
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
    required this.member,
    required this.difference,
  });

  final Member member;
  final double difference;
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/expense.dart';

class ExpenseBubble extends StatelessWidget {
  ExpenseBubble({
    super.key,
    required this.expense,
    required this.amount,
    required this.radius,
    required this.color,
  }) : _formatter = NumberFormat.currency(symbol: '€');

  final Expense expense;
  final double amount;
  final double radius;
  final Color color;
  final NumberFormat _formatter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.22),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            expense.title,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: color.darken(),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatter.format(amount),
            style: textTheme.bodySmall?.copyWith(color: color.darken()),
          ),
        ],
      ),
    );
  }
}

extension _ColorShade on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

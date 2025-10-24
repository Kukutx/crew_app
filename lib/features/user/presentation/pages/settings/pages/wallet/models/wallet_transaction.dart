import 'package:flutter/material.dart';

/// Represents a transaction displayed in the wallet activity list.
class WalletTransaction {
  const WalletTransaction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;

  bool get isExpense => amount.trim().startsWith('−');
}

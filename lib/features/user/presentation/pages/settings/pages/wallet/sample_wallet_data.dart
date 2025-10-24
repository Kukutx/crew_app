import 'package:crew_app/features/user/presentation/pages/settings/pages/wallet/models/wallet_transaction.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

List<WalletTransaction> buildSampleTransactions(
  AppLocalizations loc,
  ColorScheme colorScheme,
) {
  return [
    WalletTransaction(
      icon: Icons.emoji_events_outlined,
      iconColor: colorScheme.primary,
      title: loc.wallet_transaction_payout_title,
      subtitle: loc.wallet_transaction_payout_subtitle,
      amount: '+¥352.00',
    ),
    WalletTransaction(
      icon: Icons.refresh_outlined,
      iconColor: colorScheme.tertiary,
      title: loc.wallet_transaction_refund_title,
      subtitle: loc.wallet_transaction_refund_subtitle,
      amount: '+¥68.00',
    ),
    WalletTransaction(
      icon: Icons.auto_awesome_outlined,
      iconColor: colorScheme.secondary,
      title: loc.wallet_transaction_subscription_title,
      subtitle: loc.wallet_transaction_subscription_subtitle,
      amount: '−¥38.00',
    ),
  ];
}

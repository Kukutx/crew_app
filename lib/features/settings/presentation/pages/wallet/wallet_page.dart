import 'package:crew_app/features/settings/presentation/pages/wallet/models/wallet_transaction.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/sample_wallet_data.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/widgets/wallet_balance_card.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/widgets/wallet_help_bottom_sheet.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/widgets/wallet_insights_card.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/widgets/wallet_management_card.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/widgets/wallet_quick_actions.dart';
import 'package:crew_app/features/settings/presentation/pages/wallet/widgets/wallet_transactions_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    final List<WalletTransaction> transactions =
        buildSampleTransactions(loc, colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.wallet_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showWalletHelpBottomSheet(context),
          ),
        ],
      ),
      body: _WalletPageBody(transactions: transactions),
    );
  }
}

class _WalletPageBody extends StatelessWidget {
  const _WalletPageBody({
    required this.transactions,
  });

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WalletBalanceCard(),
          const SizedBox(height: 28),
          const WalletQuickActions(),
          const SizedBox(height: 28),
          const WalletInsightsCard(),
          const SizedBox(height: 28),
          const WalletManagementCard(),
          const SizedBox(height: 28),
          WalletTransactionsCard(transactions: transactions),
        ],
      ),
    );
  }
}

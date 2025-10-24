import 'package:crew_app/features/user/presentation/pages/settings/pages/wallet/models/wallet_transaction.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class WalletTransactionsCard extends StatelessWidget {
  const WalletTransactionsCard({
    required this.transactions,
    super.key,
  });

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                loc.wallet_recent_activity,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Text(
                  loc.wallet_activity_empty,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    leading: CrewAvatar(
                      radius: 24,
                      backgroundColor:
                          transaction.iconColor.withValues(alpha: .12),
                      foregroundColor: transaction.iconColor,
                      child: Icon(transaction.icon),
                    ),
                    title: Text(transaction.title),
                    subtitle: Text(transaction.subtitle),
                    trailing: Text(
                      transaction.amount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: transaction.isExpense
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  indent: 20,
                  endIndent: 20,
                  color: theme.dividerColor.withValues(alpha: .08),
                ),
                itemCount: transactions.length,
              ),
          ],
        ),
      ),
    );
  }
}

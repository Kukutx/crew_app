import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/providers/revenue_providers.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/widgets/revenue_balance_card.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/widgets/revenue_records_card.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/widgets/revenue_transactions_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 收益中心页面
/// 
/// 显示发起人的活动收益信息，包括：
/// - 可用余额和预留资金
/// - 活动收益记录
/// - 交易记录
class RevenuePage extends ConsumerWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final balanceAsync = ref.watch(walletBalanceProvider);
    final recordsAsync = ref.watch(revenueRecordsProvider);
    final transactionsAsync = ref.watch(revenueTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.wallet_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card_outlined),
            tooltip: loc.wallet_manage_methods,
            onPressed: () {
              context.push(AppRoutePaths.paymentMethods);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletBalanceProvider);
          ref.invalidate(revenueRecordsProvider);
          ref.invalidate(revenueTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 余额卡片
              balanceAsync.when(
                data: (balance) => RevenueBalanceCard(balance: balance),
                loading: () => const _LoadingCard(),
                error: (error, stack) => _ErrorCard(
                  message: '加载余额失败',
                  onRetry: () => ref.invalidate(walletBalanceProvider),
                ),
              ),
              const SizedBox(height: 24),
              // 活动收益记录
              recordsAsync.when(
                data: (records) => RevenueRecordsCard(records: records),
                loading: () => const _LoadingCard(),
                error: (error, stack) => _ErrorCard(
                  message: '加载收益记录失败',
                  onRetry: () => ref.invalidate(revenueRecordsProvider),
                ),
              ),
              const SizedBox(height: 24),
              // 交易记录
              transactionsAsync.when(
                data: (transactions) =>
                    RevenueTransactionsCard(transactions: transactions),
                loading: () => const _LoadingCard(),
                error: (error, stack) => _ErrorCard(
                  message: '加载交易记录失败',
                  onRetry: () => ref.invalidate(revenueTransactionsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}


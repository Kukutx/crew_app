import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/payment_method.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/revenue_record.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/revenue_transaction.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/wallet_balance.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/services/revenue_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 收益中心API服务Provider
final revenueApiServiceProvider = Provider<RevenueApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RevenueApiService(apiService: apiService);
});

/// 钱包余额Provider
final walletBalanceProvider =
    FutureProvider.autoDispose<WalletBalance>((ref) async {
  final service = ref.watch(revenueApiServiceProvider);
  return service.getBalance();
});

/// 活动收益记录Provider
final revenueRecordsProvider =
    FutureProvider.autoDispose<List<RevenueRecord>>((ref) async {
  final service = ref.watch(revenueApiServiceProvider);
  return service.getRevenueRecords();
});

/// 交易记录Provider
final revenueTransactionsProvider =
    FutureProvider.autoDispose<List<RevenueTransaction>>((ref) async {
  final service = ref.watch(revenueApiServiceProvider);
  return service.getTransactions();
});

/// 支付方式列表Provider
final paymentMethodsProvider =
    FutureProvider.autoDispose<List<PaymentMethod>>((ref) async {
  final service = ref.watch(revenueApiServiceProvider);
  return service.getPaymentMethods();
});


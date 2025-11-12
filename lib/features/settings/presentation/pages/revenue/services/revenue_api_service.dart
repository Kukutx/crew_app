import 'package:crew_app/core/network/api_service.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/payment_method.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/revenue_record.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/revenue_transaction.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/wallet_balance.dart';

/// 收益中心API服务
/// 
/// TODO: 后端API实现提醒
/// 
/// 需要实现以下后端API接口：
/// 
/// 1. GET /api/revenue/balance
///    - 获取钱包余额信息（可用余额、预留余额、总余额）
///    - 返回: WalletBalance
/// 
/// 2. GET /api/revenue/records
///    - 获取活动收益记录列表
///    - 查询参数: page, pageSize, status (可选，筛选活动状态)
///    - 返回: List<RevenueRecord>
/// 
/// 3. GET /api/revenue/transactions
///    - 获取交易记录列表
///    - 查询参数: page, pageSize, eventId (可选)
///    - 返回: List<RevenueTransaction>
/// 
/// 4. GET /api/revenue/payment-methods
///    - 获取支付方式列表
///    - 返回: List<PaymentMethod>
/// 
/// 5. POST /api/revenue/payment-methods
///    - 添加支付方式
///    - 请求体: PaymentMethod (部分字段)
///    - 返回: PaymentMethod
/// 
/// 6. PUT /api/revenue/payment-methods/{id}
///    - 更新支付方式
///    - 请求体: PaymentMethod (部分字段)
///    - 返回: PaymentMethod
/// 
/// 7. DELETE /api/revenue/payment-methods/{id}
///    - 删除支付方式
///    - 返回: 成功/失败
/// 
/// 8. POST /api/revenue/payment-methods/{id}/set-default
///    - 设置默认支付方式
///    - 返回: 成功/失败
/// 
/// Stripe集成提醒：
/// - 参与者报名时，使用Stripe Payment Intent创建预付款（capture_method: manual）
/// - 活动开始前，后端发送邮件通知用户即将扣除报名费（TODO: 后端实现邮件通知功能）
/// - 活动进行中（Event.status = ongoing），在收益中心记录每个参与者的报名费
/// - 活动结束后（Event.status = ended），使用Stripe Transfer/Payout将费用转到发起人银行账户
class RevenueApiService {
  RevenueApiService({
    required ApiService apiService,
  });

  /// 获取钱包余额
  /// 
  /// TODO: 实现后端API GET /api/revenue/balance
  Future<WalletBalance> getBalance() async {
    // TODO: 调用后端API
    // return _apiService._requestHandler.get<WalletBalance>(
    //   path: '/api/revenue/balance',
    //   requiresAuth: true,
    //   parseResponse: (data) {
    //     if (data is Map<String, dynamic>) {
    //       return WalletBalance.fromJson(data);
    //     }
    //     throw Exception('Unexpected balance payload type');
    //   },
    // );

    // 临时返回示例数据
    return const WalletBalance(
      availableBalance: 2860.00,
      reservedBalance: 320.00,
      totalBalance: 3180.00,
      lastUpdated: null,
    );
  }

  /// 获取活动收益记录列表
  /// 
  /// TODO: 实现后端API GET /api/revenue/records
  /// 
  /// 查询参数：
  /// - page: 页码（默认1）
  /// - pageSize: 每页数量（默认20）
  /// - status: 活动状态筛选（可选：reviewing, recruiting, ongoing, ended）
  Future<List<RevenueRecord>> getRevenueRecords({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    // TODO: 调用后端API
    // final queryParams = <String, dynamic>{
    //   'page': page,
    //   'pageSize': pageSize,
    // };
    // if (status != null) {
    //   queryParams['status'] = status;
    // }
    // return _apiService._requestHandler.get<List<RevenueRecord>>(
    //   path: '/api/revenue/records',
    //   queryParameters: queryParams,
    //   requiresAuth: true,
    //   parseResponse: (data) {
    //     final list = data as List<dynamic>? ?? [];
    //     return list.map((e) => RevenueRecord.fromJson(e as Map<String, dynamic>)).toList();
    //   },
    // );

    // 临时返回空列表
    return [];
  }

  /// 获取交易记录列表
  /// 
  /// TODO: 实现后端API GET /api/revenue/transactions
  /// 
  /// 查询参数：
  /// - page: 页码（默认1）
  /// - pageSize: 每页数量（默认20）
  /// - eventId: 活动ID筛选（可选）
  Future<List<RevenueTransaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? eventId,
  }) async {
    // TODO: 调用后端API
    // final queryParams = <String, dynamic>{
    //   'page': page,
    //   'pageSize': pageSize,
    // };
    // if (eventId != null) {
    //   queryParams['eventId'] = eventId;
    // }
    // return _apiService._requestHandler.get<List<RevenueTransaction>>(
    //   path: '/api/revenue/transactions',
    //   queryParameters: queryParams,
    //   requiresAuth: true,
    //   parseResponse: (data) {
    //     final list = data as List<dynamic>? ?? [];
    //     return list.map((e) => RevenueTransaction.fromJson(e as Map<String, dynamic>)).toList();
    //   },
    // );

    // 临时返回空列表
    return [];
  }

  /// 获取支付方式列表
  /// 
  /// TODO: 实现后端API GET /api/revenue/payment-methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    // TODO: 调用后端API
    // return _apiService._requestHandler.get<List<PaymentMethod>>(
    //   path: '/api/revenue/payment-methods',
    //   requiresAuth: true,
    //   parseResponse: (data) {
    //     final list = data as List<dynamic>? ?? [];
    //     return list.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList();
    //   },
    // );

    // 临时返回空列表
    return [];
  }

  /// 添加支付方式
  /// 
  /// TODO: 实现后端API POST /api/revenue/payment-methods
  Future<PaymentMethod> addPaymentMethod(PaymentMethod paymentMethod) async {
    // TODO: 调用后端API
    // return _apiService._requestHandler.post<PaymentMethod>(
    //   path: '/api/revenue/payment-methods',
    //   data: paymentMethod.toJson(),
    //   requiresAuth: true,
    //   parseResponse: (data) {
    //     if (data is Map<String, dynamic>) {
    //       return PaymentMethod.fromJson(data);
    //     }
    //     throw Exception('Unexpected payment method payload type');
    //   },
    // );

    throw UnimplementedError('后端API未实现');
  }

  /// 更新支付方式
  /// 
  /// TODO: 实现后端API PUT /api/revenue/payment-methods/{id}
  Future<PaymentMethod> updatePaymentMethod(
    String id,
    PaymentMethod paymentMethod,
  ) async {
    // TODO: 调用后端API
    // return _apiService._requestHandler.put<PaymentMethod>(
    //   path: '/api/revenue/payment-methods/$id',
    //   data: paymentMethod.toJson(),
    //   requiresAuth: true,
    //   parseResponse: (data) {
    //     if (data is Map<String, dynamic>) {
    //       return PaymentMethod.fromJson(data);
    //     }
    //     throw Exception('Unexpected payment method payload type');
    //   },
    // );

    throw UnimplementedError('后端API未实现');
  }

  /// 删除支付方式
  /// 
  /// TODO: 实现后端API DELETE /api/revenue/payment-methods/{id}
  Future<void> deletePaymentMethod(String id) async {
    // TODO: 调用后端API
    // return _apiService._requestHandler.delete(
    //   path: '/api/revenue/payment-methods/$id',
    //   requiresAuth: true,
    // );

    throw UnimplementedError('后端API未实现');
  }

  /// 设置默认支付方式
  /// 
  /// TODO: 实现后端API POST /api/revenue/payment-methods/{id}/set-default
  Future<void> setDefaultPaymentMethod(String id) async {
    // TODO: 调用后端API
    // return _apiService._requestHandler.post(
    //   path: '/api/revenue/payment-methods/$id/set-default',
    //   requiresAuth: true,
    // );

    throw UnimplementedError('后端API未实现');
  }
}


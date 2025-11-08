import 'package:flutter/material.dart';

/// 收益交易记录
/// 
/// 表示单笔交易（参与者报名费、活动结算等）
class RevenueTransaction {
  const RevenueTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.eventId,
    this.participantId,
    this.participantName,
  });

  /// 交易ID
  final String id;
  
  /// 交易类型
  final RevenueTransactionType type;
  
  /// 交易金额（正数表示收入，负数表示支出）
  final double amount;
  
  /// 交易标题
  final String title;
  
  /// 交易副标题
  final String subtitle;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 关联的活动ID
  final String? eventId;
  
  /// 参与者ID
  final String? participantId;
  
  /// 参与者姓名
  final String? participantName;

  /// 是否为收入
  bool get isIncome => amount > 0;

  /// 获取交易图标
  IconData get icon {
    switch (type) {
      case RevenueTransactionType.registrationFee:
        return Icons.person_add_outlined;
      case RevenueTransactionType.eventSettlement:
        return Icons.emoji_events_outlined;
      case RevenueTransactionType.refund:
        return Icons.refresh_outlined;
      case RevenueTransactionType.payout:
        return Icons.account_balance_wallet_outlined;
    }
  }

  /// 获取交易图标颜色
  Color getIconColor(ColorScheme colorScheme) {
    switch (type) {
      case RevenueTransactionType.registrationFee:
        return colorScheme.primary;
      case RevenueTransactionType.eventSettlement:
        return colorScheme.primary;
      case RevenueTransactionType.refund:
        return colorScheme.tertiary;
      case RevenueTransactionType.payout:
        return colorScheme.secondary;
    }
  }

  factory RevenueTransaction.fromJson(Map<String, dynamic> json) {
    return RevenueTransaction(
      id: json['id'] as String? ?? '',
      type: _parseTransactionType(json['type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      eventId: json['eventId'] as String?,
      participantId: json['participantId'] as String?,
      participantName: json['participantName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': _transactionTypeToString(type),
        'amount': amount,
        'title': title,
        'subtitle': subtitle,
        'createdAt': createdAt.toIso8601String(),
        if (eventId != null) 'eventId': eventId,
        if (participantId != null) 'participantId': participantId,
        if (participantName != null) 'participantName': participantName,
      };

  static RevenueTransactionType _parseTransactionType(String? type) {
    switch (type) {
      case 'registrationFee':
        return RevenueTransactionType.registrationFee;
      case 'eventSettlement':
        return RevenueTransactionType.eventSettlement;
      case 'refund':
        return RevenueTransactionType.refund;
      case 'payout':
        return RevenueTransactionType.payout;
      default:
        return RevenueTransactionType.registrationFee;
    }
  }

  static String _transactionTypeToString(RevenueTransactionType type) {
    switch (type) {
      case RevenueTransactionType.registrationFee:
        return 'registrationFee';
      case RevenueTransactionType.eventSettlement:
        return 'eventSettlement';
      case RevenueTransactionType.refund:
        return 'refund';
      case RevenueTransactionType.payout:
        return 'payout';
    }
  }
}

/// 交易类型
enum RevenueTransactionType {
  /// 参与者报名费（预付款）
  registrationFee,
  
  /// 活动结算（活动结束后转账到发起人账户）
  eventSettlement,
  
  /// 退款
  refund,
  
  /// 提现
  payout,
}


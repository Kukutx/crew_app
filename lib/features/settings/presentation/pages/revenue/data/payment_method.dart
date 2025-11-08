/// 支付方式类型
enum PaymentMethodType {
  /// 银行卡
  bankCard,
  
  /// PayPal
  paypal,
  
  /// Stripe账户
  stripeAccount,
  
  /// 其他
  other,
}

/// 支付方式信息
/// 
/// 用于存储发起人的收款账户信息（银行卡、PayPal等）
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.isDefault,
    this.last4Digits,
    this.bankName,
    this.accountHolderName,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  /// 支付方式ID
  final String id;
  
  /// 支付方式类型
  final PaymentMethodType type;
  
  /// 显示名称（如：尾号1234的银行卡、PayPal账户等）
  final String name;
  
  /// 是否为默认支付方式
  final bool isDefault;
  
  /// 银行卡后4位（仅银行卡类型）
  final String? last4Digits;
  
  /// 银行名称（仅银行卡类型）
  final String? bankName;
  
  /// 账户持有人姓名
  final String? accountHolderName;
  
  /// 邮箱（PayPal等）
  final String? email;
  
  /// 创建时间
  final DateTime? createdAt;
  
  /// 更新时间
  final DateTime? updatedAt;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      type: _parsePaymentMethodType(json['type'] as String?),
      name: json['name'] as String? ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
      last4Digits: json['last4Digits'] as String?,
      bankName: json['bankName'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      email: json['email'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': _paymentMethodTypeToString(type),
        'name': name,
        'isDefault': isDefault,
        if (last4Digits != null) 'last4Digits': last4Digits,
        if (bankName != null) 'bankName': bankName,
        if (accountHolderName != null) 'accountHolderName': accountHolderName,
        if (email != null) 'email': email,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  static PaymentMethodType _parsePaymentMethodType(String? type) {
    switch (type) {
      case 'bankCard':
        return PaymentMethodType.bankCard;
      case 'paypal':
        return PaymentMethodType.paypal;
      case 'stripeAccount':
        return PaymentMethodType.stripeAccount;
      case 'other':
        return PaymentMethodType.other;
      default:
        return PaymentMethodType.bankCard;
    }
  }

  static String _paymentMethodTypeToString(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bankCard:
        return 'bankCard';
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.stripeAccount:
        return 'stripeAccount';
      case PaymentMethodType.other:
        return 'other';
    }
  }
}


/// 事件注册状态
enum RegistrationStatus {
  pending,    // 待审核
  approved,   // 已批准
  rejected,   // 已拒绝
  cancelled,  // 已取消
}

/// 支付状态
enum PaymentStatus {
  pending,    // 待支付
  authorized, // 已授权（预付款）
  paid,       // 已支付
  refunded,   // 已退款
}

/// 事件注册信息
class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final String? paymentIntentId;
  final PaymentStatus? paymentStatus;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.registeredAt,
    this.paymentIntentId,
    this.paymentStatus,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: _parseRegistrationStatus(json['status'] as String?),
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : DateTime.now(),
      paymentIntentId: json['paymentIntentId'] as String?,
      paymentStatus: json['paymentStatus'] != null
          ? _parsePaymentStatus(json['paymentStatus'] as String?)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'userId': userId,
        'status': _registrationStatusToString(status),
        'registeredAt': registeredAt.toIso8601String(),
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        if (paymentStatus != null)
          'paymentStatus': _paymentStatusToString(paymentStatus!),
      };

  static RegistrationStatus _parseRegistrationStatus(String? value) {
    switch (value) {
      case 'pending':
        return RegistrationStatus.pending;
      case 'approved':
        return RegistrationStatus.approved;
      case 'rejected':
        return RegistrationStatus.rejected;
      case 'cancelled':
        return RegistrationStatus.cancelled;
      default:
        return RegistrationStatus.pending;
    }
  }

  static String _registrationStatusToString(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return 'pending';
      case RegistrationStatus.approved:
        return 'approved';
      case RegistrationStatus.rejected:
        return 'rejected';
      case RegistrationStatus.cancelled:
        return 'cancelled';
    }
  }

  static PaymentStatus _parsePaymentStatus(String? value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'authorized':
        return PaymentStatus.authorized;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static String _paymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.authorized:
        return 'authorized';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }
}




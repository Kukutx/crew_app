/// 费用模型
class Expense {
  final String id;
  final String eventId;
  final String title;
  final double amount;
  final String category;
  final DateTime timestamp;
  final String paidBy;
  final String paidByName;
  final List<String> sharedBy;
  final List<String> sharedByNames;
  final String? paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.eventId,
    required this.title,
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.paidBy,
    required this.paidByName,
    required this.sharedBy,
    required this.sharedByNames,
    this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      paidBy: json['paidBy'] as String? ?? '',
      paidByName: json['paidByName'] as String? ?? '',
      sharedBy: (json['sharedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sharedByNames: (json['sharedByNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      paymentMethod: json['paymentMethod'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'title': title,
        'amount': amount,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'paidBy': paidBy,
        'paidByName': paidByName,
        'sharedBy': sharedBy,
        'sharedByNames': sharedByNames,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (note != null) 'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// 费用创建请求
class ExpenseCreateRequest {
  final String eventId;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final List<String> sharedBy;
  final String? paymentMethod;
  final String? note;

  const ExpenseCreateRequest({
    required this.eventId,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.sharedBy,
    this.paymentMethod,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'title': title,
        'amount': amount,
        'category': category,
        'paidBy': paidBy,
        'sharedBy': sharedBy,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (note != null) 'note': note,
      };
}

/// 费用更新请求
class ExpenseUpdateRequest extends ExpenseCreateRequest {
  final String id;

  const ExpenseUpdateRequest({
    required this.id,
    required super.eventId,
    required super.title,
    required super.amount,
    required super.category,
    required super.paidBy,
    required super.sharedBy,
    super.paymentMethod,
    super.note,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        ...super.toJson(),
      };
}

/// 费用结算
class ExpenseSettlement {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;

  const ExpenseSettlement({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
  });

  factory ExpenseSettlement.fromJson(Map<String, dynamic> json) {
    return ExpenseSettlement(
      fromUserId: json['fromUserId'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? '',
      toUserName: json['toUserName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'toUserId': toUserId,
        'toUserName': toUserName,
        'amount': amount,
      };
}

/// 成员费用汇总
class MemberExpenseSummary {
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double totalPaid;
  final double totalOwed;
  final double balance;
  final bool isHost;

  const MemberExpenseSummary({
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.totalPaid,
    required this.totalOwed,
    required this.balance,
    this.isHost = false,
  });

  factory MemberExpenseSummary.fromJson(Map<String, dynamic> json) {
    return MemberExpenseSummary(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      totalOwed: (json['totalOwed'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isHost: (json['isHost'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
        'totalPaid': totalPaid,
        'totalOwed': totalOwed,
        'balance': balance,
        'isHost': isHost,
      };
}




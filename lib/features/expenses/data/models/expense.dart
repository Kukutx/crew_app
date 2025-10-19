import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable(explicitToJson: true)
class Member {
  const Member({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.total = 0,
  });

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);

  final String id;
  final String name;
  final String? avatarUrl;
  final double total;

  Member copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    double? total,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      total: total ?? this.total,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExpenseShare {
  const ExpenseShare({
    required this.memberId,
    this.ratio,
    this.assigned,
    this.computed,
  });

  factory ExpenseShare.fromJson(Map<String, dynamic> json) =>
      _$ExpenseShareFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseShareToJson(this);

  final String memberId;
  final double? ratio;
  final double? assigned;
  final double? computed;

  ExpenseShare copyWith({
    String? memberId,
    double? ratio,
    double? assigned,
    double? computed,
  }) {
    return ExpenseShare(
      memberId: memberId ?? this.memberId,
      ratio: ratio ?? this.ratio,
      assigned: assigned ?? this.assigned,
      computed: computed ?? this.computed,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Expense {
  const Expense({
    required this.id,
    required this.eventId,
    required this.payerId,
    required this.title,
    required this.amount,
    required this.createdAt,
    required this.shares,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  final String id;
  final String eventId;
  final String payerId;
  final String title;
  final double amount;
  final DateTime createdAt;
  final List<ExpenseShare> shares;
}

@JsonSerializable(explicitToJson: true)
class Transfer {
  const Transfer({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);

  Map<String, dynamic> toJson() => _$TransferToJson(this);

  final String fromMemberId;
  final String toMemberId;
  final double amount;
}

@JsonSerializable(explicitToJson: true)
class Settlement {
  const Settlement({
    required this.transfers,
    required this.balances,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);

  Map<String, dynamic> toJson() => _$SettlementToJson(this);

  final List<Transfer> transfers;
  final Map<String, double> balances;
}

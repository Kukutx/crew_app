// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'total': instance.total,
    };

ExpenseShare _$ExpenseShareFromJson(Map<String, dynamic> json) => ExpenseShare(
      memberId: json['memberId'] as String,
      ratio: (json['ratio'] as num?)?.toDouble(),
      assigned: (json['assigned'] as num?)?.toDouble(),
      computed: (json['computed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExpenseShareToJson(ExpenseShare instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'ratio': instance.ratio,
      'assigned': instance.assigned,
      'computed': instance.computed,
    };

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      payerId: json['payerId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      shares: (json['shares'] as List<dynamic>)
          .map((e) => ExpenseShare.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'payerId': instance.payerId,
      'title': instance.title,
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'shares': instance.shares.map((e) => e.toJson()).toList(),
    };

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
      fromMemberId: json['fromMemberId'] as String,
      toMemberId: json['toMemberId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      'fromMemberId': instance.fromMemberId,
      'toMemberId': instance.toMemberId,
      'amount': instance.amount,
    };

Settlement _$SettlementFromJson(Map<String, dynamic> json) => Settlement(
      transfers: (json['transfers'] as List<dynamic>)
          .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
          .toList(),
      balances: (json['balances'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$SettlementToJson(Settlement instance) =>
    <String, dynamic>{
      'transfers': instance.transfers.map((e) => e.toJson()).toList(),
      'balances': instance.balances,
    };

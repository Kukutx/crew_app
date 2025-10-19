import 'package:crew_app/features/expenses/data/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expenses_api.dart';

class ExpensesSnapshot {
  const ExpensesSnapshot({
    required this.members,
    required this.expenses,
  });

  final List<Member> members;
  final List<Expense> expenses;
}

class AddExpenseRequest {
  const AddExpenseRequest({
    required this.title,
    required this.amount,
    required this.payerId,
    required List<ExpenseShare> shares,
    this.createdAt,
  }) : shares = List<ExpenseShare>.unmodifiable(shares);

  final String title;
  final double amount;
  final String payerId;
  final List<ExpenseShare> shares;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'amount': amount,
      'payerId': payerId,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'shares': shares.map((share) => share.toJson()).toList(),
    };
  }
}

class ExpensesRepository {
  ExpensesRepository(this._api);

  final ExpensesApi _api;

  Future<ExpensesSnapshot> fetchExpenses(String eventId) async {
    final payload = await _api.getExpenses(eventId);
    final members = _parseMembers(payload['members']);
    final expenses = _parseExpenses(payload['expenses']);
    return ExpensesSnapshot(members: members, expenses: expenses);
  }

  Future<Expense> createExpense({
    required String eventId,
    required AddExpenseRequest request,
  }) async {
    final payload = await _api.createExpense(
      eventId: eventId,
      payload: request.toJson(),
    );
    final rawExpense = _unwrapExpense(payload);
    return Expense.fromJson(rawExpense);
  }

  Future<void> deleteExpense({
    required String eventId,
    required String expenseId,
  }) {
    return _api.deleteExpense(eventId: eventId, expenseId: expenseId);
  }

  Future<Settlement> fetchSettlementPreview(String eventId) async {
    final payload = await _api.getSettlement(eventId);
    final rawSettlement = _unwrapSettlement(payload);
    return Settlement.fromJson(rawSettlement);
  }

  List<Member> _parseMembers(dynamic raw) {
    final list = _unwrapList(raw);
    return list
        .whereType<Map>()
        .map((item) => Member.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<Expense> _parseExpenses(dynamic raw) {
    final list = _unwrapList(raw);
    return list
        .whereType<Map>()
        .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Map<String, dynamic> _unwrapExpense(Map<String, dynamic> payload) {
    for (final key in const ['expense', 'data', 'result']) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return payload;
  }

  Map<String, dynamic> _unwrapSettlement(Map<String, dynamic> payload) {
    for (final key in const ['settlement', 'data', 'result']) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return payload;
  }

  List<dynamic> _unwrapList(dynamic raw) {
    if (raw is List<dynamic>) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      for (final key in const ['items', 'data', 'value', 'results']) {
        final value = raw[key];
        if (value is List<dynamic>) {
          return value;
        }
      }
    }
    return const <dynamic>[];
  }
}

final expensesApiProvider = Provider<ExpensesApi>((ref) {
  return ExpensesApi();
});

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(ref.watch(expensesApiProvider));
});

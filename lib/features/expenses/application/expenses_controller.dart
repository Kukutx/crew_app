import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expenses_repository.dart';
import '../data/models/expense.dart';
import 'settlement_calculator.dart';

class ExpensesState {
  const ExpensesState({
    required this.members,
    required this.expenses,
    this.previewSettlement,
  });

  final List<Member> members;
  final List<Expense> expenses;
  final Settlement? previewSettlement;

  ExpensesState copyWith({
    List<Member>? members,
    List<Expense>? expenses,
    Settlement? previewSettlement,
    bool clearPreview = false,
  }) {
    return ExpensesState(
      members: members ?? this.members,
      expenses: expenses ?? this.expenses,
      previewSettlement: clearPreview
          ? null
          : (previewSettlement ?? this.previewSettlement),
    );
  }
}

final expensesControllerProvider = AutoDisposeAsyncNotifierProviderFamily<
    ExpensesController,
    ExpensesState,
    String>(ExpensesController.new);

class ExpensesController extends AutoDisposeFamilyAsyncNotifier<
    ExpensesState, String> {
  late final ExpensesRepository _repository;
  late final SettlementCalculator _calculator;

  @override
  Future<ExpensesState> build(String arg) async {
    _repository = ref.watch(expensesRepositoryProvider);
    _calculator = const SettlementCalculator();
    final snapshot = await _repository.fetchExpenses(arg);
    return _composeState(snapshot.members, snapshot.expenses);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ExpensesState>();
    state = await AsyncValue.guard(() async {
      final snapshot = await _repository.fetchExpenses(arg);
      return _composeState(snapshot.members, snapshot.expenses);
    });
  }

  Future<void> addExpense(AddExpenseRequest request) async {
    final previous = state.valueOrNull;
    state = const AsyncLoading<ExpensesState>();
    state = await AsyncValue.guard(() async {
      final members = previous?.members ?? <Member>[];
      final expenses = previous?.expenses ?? <Expense>[];
      final expense = await _repository.createExpense(
        eventId: arg,
        request: request,
      );
      final updatedExpenses = [...expenses, expense]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _composeState(members, updatedExpenses);
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    final previous = state.valueOrNull;
    state = const AsyncLoading<ExpensesState>();
    state = await AsyncValue.guard(() async {
      final members = previous?.members ?? <Member>[];
      final expenses = previous?.expenses ?? <Expense>[];
      await _repository.deleteExpense(eventId: arg, expenseId: expenseId);
      final updatedExpenses =
          expenses.where((expense) => expense.id != expenseId).toList();
      updatedExpenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _composeState(members, updatedExpenses);
    });
  }

  Future<Settlement> previewSettlement() async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Expenses data not loaded');
    }
    final preview = _calculator.computePreview(current.expenses);
    state = AsyncData(current.copyWith(previewSettlement: preview));
    return preview;
  }

  ExpensesState _composeState(
    List<Member> members,
    List<Expense> expenses,
  ) {
    final memberTotals = _calculator.computeBalances(expenses)
        .map((key, value) => MapEntry(key, value.abs()));
    final memberMap = {for (final member in members) member.id: member};
    final updatedMembers = <Member>[];
    for (final entry in memberMap.entries) {
      updatedMembers.add(
        entry.value.copyWith(total: memberTotals[entry.key] ?? entry.value.total),
      );
    }
    for (final id in memberTotals.keys) {
      if (memberMap.containsKey(id)) {
        continue;
      }
      updatedMembers.add(
        Member(id: id, name: id, total: memberTotals[id] ?? 0),
      );
    }
    return ExpensesState(
      members: updatedMembers,
      expenses: List<Expense>.unmodifiable(expenses),
    );
  }
}

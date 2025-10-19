import 'package:crew_app/features/expenses/application/expenses_controller.dart';
import 'package:crew_app/features/expenses/data/expenses_repository.dart';
import 'package:crew_app/features/expenses/data/models/expense.dart';
import 'package:crew_app/features/expenses/presentation/add_expense_sheet.dart';
import 'package:crew_app/features/expenses/presentation/bubble_expense_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping member bubble opens detail sheet', (tester) async {
    final members = [
      const Member(id: 'alice', name: 'Alice', total: 60),
      const Member(id: 'bob', name: 'Bob', total: 30),
    ];
    final expenses = [
      Expense(
        id: '1',
        eventId: 'event',
        payerId: 'alice',
        title: 'Dinner',
        amount: 90,
        createdAt: DateTime(2024, 1, 1),
        shares: const [
          ExpenseShare(memberId: 'alice', assigned: 60, computed: 60),
          ExpenseShare(memberId: 'bob', assigned: 30, computed: 30),
        ],
      ),
    ];
    final state = ExpensesState(members: members, expenses: expenses);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expensesControllerProvider.overrideWith((eventId) {
            return _StubExpensesController(state);
          }),
        ],
        child: const MaterialApp(
          home: BubbleExpensePage(eventId: 'event'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(find.text('Alice 的消费'), findsOneWidget);
  });

  testWidgets('add expense form validates required fields', (tester) async {
    final members = [
      const Member(id: 'alice', name: 'Alice', total: 0),
      const Member(id: 'bob', name: 'Bob', total: 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddExpenseSheet(
            members: members,
            onSubmit: (_) async {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('保存'));
    await tester.pump();

    expect(find.text('请输入标题'), findsOneWidget);
    expect(find.text('请输入大于 0 的金额'), findsOneWidget);
    expect(find.text('请选择支付者'), findsOneWidget);
  });
}

class _StubExpensesController extends ExpensesController {
  _StubExpensesController(this._state);

  final ExpensesState _state;

  @override
  Future<ExpensesState> build(String arg) async {
    return _state;
  }

  @override
  Future<void> addExpense(AddExpenseRequest request) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<Settlement> previewSettlement() async {
    return const Settlement(transfers: [], balances: {});
  }
}

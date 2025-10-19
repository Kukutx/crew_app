import 'package:flutter_test/flutter_test.dart';

import 'package:crew_app/features/expenses/application/settlement_calculator.dart';
import 'package:crew_app/features/expenses/data/models/expense.dart';

void main() {
  group('SettlementCalculator', () {
    const calculator = SettlementCalculator();

    test('returns empty settlement when no expenses', () {
      final settlement = calculator.computePreview(const <Expense>[]);
      expect(settlement.transfers, isEmpty);
      expect(settlement.balances, isEmpty);
    });

    test('splits a single shared expense correctly', () {
      final expenses = [
        Expense(
          id: '1',
          eventId: 'event',
          payerId: 'alice',
          title: 'Dinner',
          amount: 90,
          createdAt: DateTime(2024, 1, 1),
          shares: const [
            ExpenseShare(memberId: 'alice', assigned: 30, computed: 30),
            ExpenseShare(memberId: 'bob', assigned: 30, computed: 30),
            ExpenseShare(memberId: 'carol', assigned: 30, computed: 30),
          ],
        ),
      ];

      final settlement = calculator.computePreview(expenses);
      expect(settlement.balances['alice'], closeTo(60, 0.01));
      expect(settlement.balances['bob'], closeTo(-30, 0.01));
      expect(settlement.balances['carol'], closeTo(-30, 0.01));
      expect(settlement.transfers.length, 2);
      expect(
        settlement.transfers.map((transfer) => transfer.amount).reduce((a, b) => a + b),
        closeTo(60, 0.01),
      );
    });

    test('rounds floating point errors to nearest cent', () {
      final expenses = [
        Expense(
          id: '2',
          eventId: 'event',
          payerId: 'alice',
          title: 'Taxi',
          amount: 10,
          createdAt: DateTime(2024, 1, 1),
          shares: const [
            ExpenseShare(memberId: 'alice', ratio: 1),
            ExpenseShare(memberId: 'bob', ratio: 1),
          ],
        ),
        Expense(
          id: '3',
          eventId: 'event',
          payerId: 'bob',
          title: 'Coffee',
          amount: 3,
          createdAt: DateTime(2024, 1, 2),
          shares: const [
            ExpenseShare(memberId: 'alice', ratio: 1),
            ExpenseShare(memberId: 'bob', ratio: 1),
          ],
        ),
      ];

      final settlement = calculator.computePreview(expenses);
      final totalBalance = settlement.balances.values.reduce((value, element) => value + element);
      expect(totalBalance, closeTo(0, 0.01));
      for (final balance in settlement.balances.values) {
        expect((balance * 100).roundToDouble() / 100, balance);
      }
    });
  });
}

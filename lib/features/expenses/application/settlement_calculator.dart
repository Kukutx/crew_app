import 'dart:math';

import 'package:collection/collection.dart';

import '../data/models/expense.dart';

class SettlementCalculator {
  const SettlementCalculator();

  Settlement computePreview(List<Expense> expenses) {
    final balances = computeBalances(expenses);
    final creditors = <_BalanceEntry>[];
    final debtors = <_BalanceEntry>[];

    balances.forEach((memberId, balance) {
      if (balance > _epsilon) {
        creditors.add(_BalanceEntry(memberId, balance));
      } else if (balance < -_epsilon) {
        debtors.add(_BalanceEntry(memberId, balance));
      }
    });

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => a.amount.compareTo(b.amount));

    final transfers = <Transfer>[];
    var creditorIndex = 0;
    var debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];
      final amount = min(creditor.amount, -debtor.amount);

      if (amount > _epsilon) {
        transfers.add(
          Transfer(
            fromMemberId: debtor.memberId,
            toMemberId: creditor.memberId,
            amount: _roundToCent(amount),
          ),
        );
      }

      creditors[creditorIndex] = creditor.copyWith(amount: creditor.amount - amount);
      debtors[debtorIndex] = debtor.copyWith(amount: debtor.amount + amount);

      if (creditors[creditorIndex].amount <= _epsilon) {
        creditorIndex++;
      }
      if (debtors[debtorIndex].amount >= -_epsilon) {
        debtorIndex++;
      }
    }

    final roundedBalances = balances.map(
      (key, value) => MapEntry(key, _roundToCent(value)),
    );

    return Settlement(transfers: transfers, balances: roundedBalances);
  }

  Map<String, double> computeBalances(List<Expense> expenses) {
    final paid = <String, double>{};
    final owed = <String, double>{};

    for (final expense in expenses) {
      paid.update(expense.payerId, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
      for (final share in expense.shares) {
        final shareAmount = shareAmountFor(expense, share.memberId);
        if (shareAmount <= 0) {
          continue;
        }
        owed.update(share.memberId, (value) => value + shareAmount,
            ifAbsent: () => shareAmount);
      }
    }

    final members = {...paid.keys, ...owed.keys};
    final balances = <String, double>{};
    for (final memberId in members) {
      final net = (paid[memberId] ?? 0) - (owed[memberId] ?? 0);
      balances[memberId] = net;
    }
    return balances;
  }

  double shareAmountFor(Expense expense, String memberId) {
    final share = expense.shares.firstWhereOrNull(
      (share) => share.memberId == memberId,
    );
    if (share == null) {
      return 0;
    }
    if (share.assigned != null) {
      return share.assigned!.toDouble();
    }
    if (share.computed != null) {
      return share.computed!.toDouble();
    }
    final ratioShares = expense.shares
        .where((element) => element.assigned == null && element.computed == null)
        .toList(growable: false);
    final ratioSum =
        ratioShares.fold<double>(0, (sum, item) => sum + (item.ratio ?? 0));
    if (ratioSum <= 0) {
      return 0;
    }
    final ratio = share.ratio ?? 0;
    if (ratio <= 0) {
      return 0;
    }
    return expense.amount * (ratio / ratioSum);
  }

  static const double _epsilon = 0.0001;

  double _roundToCent(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}

class _BalanceEntry {
  const _BalanceEntry(this.memberId, this.amount);

  final String memberId;
  final double amount;

  _BalanceEntry copyWith({String? memberId, double? amount}) {
    return _BalanceEntry(memberId ?? this.memberId, amount ?? this.amount);
  }
}

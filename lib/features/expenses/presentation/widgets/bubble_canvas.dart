import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../application/settlement_calculator.dart';
import '../../data/models/expense.dart';
import 'expense_bubble.dart';
import 'member_bubble.dart';

typedef MemberTapCallback = void Function(Member member);

class BubbleCanvas extends StatelessWidget {
  const BubbleCanvas({
    super.key,
    required this.members,
    required this.expenses,
    required this.onMemberTap,
  });

  final List<Member> members;
  final List<Expense> expenses;
  final MemberTapCallback onMemberTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final layout = _BubbleLayoutCalculator(
          members: members,
          expenses: expenses,
        ).calculate(size);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final memberLayout in layout)
              Positioned(
                left: memberLayout.center.dx - memberLayout.radius,
                top: memberLayout.center.dy - memberLayout.radius,
                child: MemberBubble(
                  member: memberLayout.member,
                  radius: memberLayout.radius,
                  color: memberLayout.color,
                  onTap: () => onMemberTap(memberLayout.member),
                ),
              ),
            for (final memberLayout in layout)
              for (final expenseLayout in memberLayout.expenses)
                Positioned(
                  left: expenseLayout.center.dx - expenseLayout.radius,
                  top: expenseLayout.center.dy - expenseLayout.radius,
                  child: ExpenseBubble(
                    expense: expenseLayout.expense,
                    amount: expenseLayout.amount,
                    radius: expenseLayout.radius,
                    color: memberLayout.color,
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _BubbleLayoutCalculator {
  _BubbleLayoutCalculator({
    required this.members,
    required this.expenses,
  });

  final List<Member> members;
  final List<Expense> expenses;
  final SettlementCalculator _calculator = const SettlementCalculator();

  List<_MemberLayout> calculate(Size size) {
    if (members.isEmpty) {
      return const <_MemberLayout>[];
    }

    final memberTotals = {
      for (final member in members) member.id: member.total,
    };
    final colors = _generatePalette(members.length);
    final radii = {
      for (final member in members)
        member.id: _computeRadius(memberTotals[member.id] ?? 0),
    };
    final maxRadius = radii.values.fold<double>(0, math.max);
    final centers = _computeMemberCenters(size, members.length, maxRadius);

    final layouts = <_MemberLayout>[];
    for (var index = 0; index < members.length; index++) {
      final member = members[index];
      final center = centers[index];
      final radius = radii[member.id] ?? _minRadius;
      final color = colors[index % colors.length];
      final memberExpenses = _memberExpenses(member.id);
      final expenseLayouts = _computeExpenseLayouts(
        memberExpenses,
        center,
        radius,
      );
      layouts.add(
        _MemberLayout(
          member: member,
          center: center,
          radius: radius,
          color: color,
          expenses: expenseLayouts,
        ),
      );
    }

    return layouts;
  }

  List<_ExpenseLayout> _memberExpenses(String memberId) {
    final list = <_ExpenseLayout>[];
    for (final expense in expenses) {
      final amount = _calculator.shareAmountFor(expense, memberId);
      if (amount <= 0) {
        continue;
      }
      final radius = _computeExpenseRadius(amount);
      list.add(
        _ExpenseLayout(
          expense: expense,
          amount: amount,
          radius: radius,
          center: Offset.zero,
        ),
      );
    }
    return list;
  }

  List<_ExpenseLayout> _computeExpenseLayouts(
    List<_ExpenseLayout> entries,
    Offset center,
    double baseRadius,
  ) {
    if (entries.isEmpty) {
      return entries;
    }
    var angle = math.pi / 4;
    var distance = baseRadius + 40;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final dx = center.dx + math.cos(angle) * distance;
      final dy = center.dy + math.sin(angle) * distance;
      entries[index] = entry.copyWith(
        center: Offset(dx, dy),
      );
      angle += math.pi * 0.45;
      distance += entry.radius * 1.2;
    }
    return entries;
  }

  List<Color> _generatePalette(int count) {
    final seed = Colors.teal;
    final swatches = <Color>[];
    for (var index = 0; index < count; index++) {
      final hueShift = (index * 360 / math.max(count, 1)) % 360;
      final hsl = HSLColor.fromColor(seed).withHue(hueShift);
      swatches.add(hsl.toColor());
    }
    return swatches;
  }

  double _computeRadius(double total) {
    final sanitized = total <= 0 ? 1 : total;
    final radius = _radiusScale * math.sqrt(sanitized);
    return radius.clamp(_minRadius, _maxRadius);
  }

  double _computeExpenseRadius(double amount) {
    final sanitized = amount <= 0 ? 1 : amount;
    final radius = _expenseRadiusScale * math.sqrt(sanitized);
    return radius.clamp(18, 60);
  }

  List<Offset> _computeMemberCenters(Size size, int count, double maxRadius) {
    final centers = <Offset>[];
    final width = size.width;
    final height = size.height;
    if (count == 1) {
      centers.add(Offset(width / 2, height / 2));
      return centers;
    }
    if (count == 2) {
      final offsetX = width / 2 - maxRadius - 40;
      final y = height / 2;
      centers.add(Offset(width / 2 - offsetX, y));
      centers.add(Offset(width / 2 + offsetX, y));
      return centers;
    }
    final center = Offset(width / 2, height / 2);
    final radius = math.max(
      math.min(width, height) / 2 - maxRadius - 48,
      maxRadius + 16,
    );
    for (var index = 0; index < count; index++) {
      final angle = (2 * math.pi * index) / count;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      centers.add(Offset(dx, dy));
    }
    return centers;
  }

  static const double _radiusScale = 14;
  static const double _expenseRadiusScale = 6;
  static const double _minRadius = 64;
  static const double _maxRadius = 144;
}

class _MemberLayout {
  const _MemberLayout({
    required this.member,
    required this.center,
    required this.radius,
    required this.color,
    required this.expenses,
  });

  final Member member;
  final Offset center;
  final double radius;
  final Color color;
  final List<_ExpenseLayout> expenses;
}

class _ExpenseLayout {
  const _ExpenseLayout({
    required this.expense,
    required this.amount,
    required this.radius,
    required this.center,
  });

  final Expense expense;
  final double amount;
  final double radius;
  final Offset center;

  _ExpenseLayout copyWith({
    Expense? expense,
    double? amount,
    double? radius,
    Offset? center,
  }) {
    return _ExpenseLayout(
      expense: expense ?? this.expense,
      amount: amount ?? this.amount,
      radius: radius ?? this.radius,
      center: center ?? this.center,
    );
  }
}

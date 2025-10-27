import 'dart:math' as math;

import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/features/expenses/widgets/avatar.dart';
import 'package:flutter/material.dart';

class ParticipantBubble extends StatefulWidget {
  const ParticipantBubble({
    super.key,
    required this.participant,
    required this.onTap,
    required this.onExpenseTap,
    this.bubbleDiameter = defaultBubbleDiameter,
    this.expenseBubbleDiameter = defaultExpenseBubbleDiameter,
    this.expenseAngles,
  });

  final Participant participant;
  final VoidCallback onTap;
  final ValueChanged<ParticipantExpense> onExpenseTap;
  final double bubbleDiameter;
  final double expenseBubbleDiameter;
  final List<double>? expenseAngles;

  static const double defaultBubbleDiameter = 200;
  static const double defaultExpenseBubbleDiameter = 72;
  static const double _expenseOrbitPadding = 48;

  static double outerExtent({
    required double bubbleDiameter,
    required double expenseBubbleDiameter,
  }) {
    final orbitRadius = bubbleDiameter / 2 + _expenseOrbitPadding;
    return (orbitRadius + expenseBubbleDiameter / 2) * 2;
  }

  @override
  State<ParticipantBubble> createState() => _ParticipantBubbleState();
}

class _ParticipantBubbleState extends State<ParticipantBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + (widget.participant.total * 4).toInt()),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    final bubbleSize = widget.bubbleDiameter;
    final expenses = participant.expenses;
    final orbitRadius = bubbleSize / 2 + _expenseOrbitPadding;
    final stackExtent = (orbitRadius + widget.expenseBubbleDiameter / 2) * 2;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final expenseBubbleStart = isDark
        ? const Color(0xCC4C5CFF)
        : const Color(0xAA81A4FF);
    final expenseBubbleEnd = isDark
        ? const Color(0x882B2E4F)
        : Colors.white.withValues(alpha: 0.75);
    final expenseBorderColor = isDark
        ? const Color(0x663C3F71)
        : const Color(0x5581A4FF);
    final expenseShadowColor = isDark
        ? const Color(0x332B2E4F)
        : const Color(0x3381A4FF);
    final mainGradientBase = isDark
        ? const [Color(0xFF4F46E5), Color(0xFF9333EA)]
        : const [Color(0xFF5B8DEF), Color(0xFF7C3AED)];
    final mainGradient = mainGradientBase
        .map(
          (color) => color.withValues(
            alpha: isDark ? 0.72 : 0.78,
          ),
        )
        .toList();
    final bubbleShadowColor = isDark
        ? Colors.black.withOpacity(0.4)
        : const Color(0x335B8DEF);
    final primaryContentColor = isDark ? Colors.white : scheme.onPrimary;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.85)
        : scheme.onPrimary.withValues(alpha: .8);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = math.sin(_controller.value * math.pi * 2) * 6;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: SizedBox(
        width: stackExtent,
        height: stackExtent,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ...List.generate(expenses.length, (index) {
              final expense = expenses[index];
              final size = widget.expenseBubbleDiameter;
              final angles = widget.expenseAngles;
              final hasCustomAngles =
                  angles != null && angles.length == expenses.length;
              final angle = hasCustomAngles
                  ? angles[index]
                  : (2 * math.pi / expenses.length) * index - math.pi / 2;
              final dx = math.cos(angle) * orbitRadius;
              final dy = math.sin(angle) * orbitRadius;
              return Positioned(
                left: stackExtent / 2 + dx - size / 2,
                top: stackExtent / 2 + dy - size / 2,
                child: GestureDetector(
                  onTap: () => widget.onExpenseTap(expense),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          expenseBubbleStart,
                          expenseBubbleEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: expenseBorderColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: expenseShadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        NumberFormatHelper.shortCurrency(expense.amount),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xFF1B2A75),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: mainGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bubbleShadowColor,
                      blurRadius: isDark ? 30 : 20,
                      offset: const Offset(0, 18),
                    ),
                  ],
                  border: Border.all(
                    color: borderColor,
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Avatar(
                        name: participant.name,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        participant.name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                              color: primaryContentColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormatHelper.currency.format(participant.total),
                        style: theme.textTheme.headlineSmall?.copyWith(
                              color: primaryContentColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

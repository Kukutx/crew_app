import 'dart:math' as math;

import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/features/expenses/widgets/avatar.dart';
import 'package:flutter/material.dart';

class ParticipantBubble extends StatefulWidget {
  const ParticipantBubble({
    super.key,
    required this.participant,
    required this.maxTotal,
    required this.onTap,
    required this.onExpenseTap,
  });

  final Participant participant;
  final double maxTotal;
  final VoidCallback onTap;
  final ValueChanged<ParticipantExpense> onExpenseTap;

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
    final normalized = widget.maxTotal == 0
        ? 0.0
        : (participant.total / widget.maxTotal).clamp(0.0, 1.0);
    const bubbleSize = 220.0;
    final expenses = participant.expenses;
    final baseRadius = bubbleSize / 2 + 36 + normalized * 12;
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
    final mainGradient = isDark
        ? const [Color(0xFF4F46E5), Color(0xFF9333EA)]
        : const [Color(0xFF5B8DEF), Color(0xFF7C3AED)];
    final bubbleShadowColor = isDark
        ? Colors.black.withOpacity(0.4)
        : const Color(0x335B8DEF);
    final primaryContentColor = isDark ? Colors.white : scheme.onPrimary;

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
        width: bubbleSize + 140,
        height: bubbleSize + 140,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ...List.generate(expenses.length, (index) {
              final expense = expenses[index];
              final ratio = participant.total == 0
                  ? 0.0
                  : (expense.amount / participant.total).clamp(0.0, 1.0);
              final size = 38.0 + ratio * 60;
              final angle = (2 * math.pi / expenses.length) * index;
              final dx = math.cos(angle) * (baseRadius + (index.isEven ? 10 : -6));
              final dy = math.sin(angle) * (baseRadius + (index.isOdd ? 6 : -8));
              return Positioned(
                left: (bubbleSize + 140) / 2 + dx - size / 2,
                top: (bubbleSize + 140) / 2 + dy - size / 2,
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
                  border: participant.isCreator
                      ? Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.85)
                              : scheme.onPrimary.withValues(alpha: .8),
                          width: 3,
                        )
                      : null,
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

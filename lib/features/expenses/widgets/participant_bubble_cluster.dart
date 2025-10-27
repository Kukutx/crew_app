import 'dart:math' as math;

import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/features/expenses/widgets/participant_bubble.dart';
import 'package:flutter/material.dart';

class ParticipantBubbleCluster extends StatelessWidget {
  const ParticipantBubbleCluster({
    super.key,
    required this.participants,
    required this.onParticipantTap,
    required this.onExpenseTap,
  });

  final List<Participant> participants;
  final ValueChanged<Participant> onParticipantTap;
  final void Function(Participant, ParticipantExpense) onExpenseTap;

  static const double _bubbleDiameter = 200;
  static const double _expenseBubbleDiameter = 72;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayParticipants = participants.take(7).toList();
    final offsets = _positionsForCount(displayParticipants.length);
    final outerExtent = ParticipantBubble.outerExtent(
      bubbleDiameter: _bubbleDiameter,
      expenseBubbleDiameter: _expenseBubbleDiameter,
    );

    double maxX = 0;
    double maxY = 0;
    for (final offset in offsets) {
      maxX = math.max(maxX, offset.dx.abs() + outerExtent / 2);
      maxY = math.max(maxY, offset.dy.abs() + outerExtent / 2);
    }

    final size = Size(maxX * 2, maxY * 2);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          for (var i = 0; i < displayParticipants.length; i++)
            _buildParticipant(
              participant: displayParticipants[i],
              offset: offsets[i],
              canvasSize: size,
              extent: outerExtent,
            ),
        ],
      ),
    );
  }

  Widget _buildParticipant({
    required Participant participant,
    required Offset offset,
    required Size canvasSize,
    required double extent,
  }) {
    final center = Offset(
      canvasSize.width / 2 + offset.dx,
      canvasSize.height / 2 + offset.dy,
    );

    return Positioned(
      left: center.dx - extent / 2,
      top: center.dy - extent / 2,
      width: extent,
      height: extent,
      child: ParticipantBubble(
        participant: participant,
        bubbleDiameter: _bubbleDiameter,
        expenseBubbleDiameter: _expenseBubbleDiameter,
        onTap: () => onParticipantTap(participant),
        onExpenseTap: (expense) => onExpenseTap(participant, expense),
      ),
    );
  }

  List<Offset> _positionsForCount(int count) {
    const radius = _bubbleDiameter * 0.78;
    const innerRadius = _bubbleDiameter * 0.48;

    switch (count) {
      case 1:
        return [Offset.zero];
      case 2:
        return [
          const Offset(-innerRadius, 0),
          const Offset(innerRadius, 0),
        ];
      case 3:
        return [
          const Offset(0, -innerRadius),
          Offset(-innerRadius * 0.9, innerRadius * 0.9),
          Offset(innerRadius * 0.9, innerRadius * 0.9),
        ];
      case 4:
        return [
          const Offset(0, -radius * 0.72),
          const Offset(-radius * 0.72, 0),
          const Offset(radius * 0.72, 0),
          const Offset(0, radius * 0.72),
        ];
      case 5:
        return [
          Offset.zero,
          const Offset(-radius * 0.78, -radius * 0.1),
          const Offset(radius * 0.78, -radius * 0.1),
          const Offset(-radius * 0.45, radius * 0.8),
          const Offset(radius * 0.45, radius * 0.8),
        ];
      case 6:
        return _ringPositions(6, radius, startAngle: -math.pi / 2);
      case 7:
        return [
          Offset.zero,
          ..._ringPositions(6, radius, startAngle: -math.pi / 2),
        ];
      default:
        return _ringPositions(count, radius, startAngle: -math.pi / 2);
    }
  }

  List<Offset> _ringPositions(int count, double radius, {double startAngle = 0}) {
    return List.generate(count, (index) {
      final angle = startAngle + (2 * math.pi / count) * index;
      return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
    });
  }
}

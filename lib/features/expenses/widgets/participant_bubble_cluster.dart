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
    final expenseRadius = _expenseBubbleDiameter / 2;
    final orbitRadius = outerExtent / 2 - expenseRadius;

    double maxX = 0;
    double maxY = 0;
    for (final offset in offsets) {
      maxX = math.max(maxX, offset.dx.abs() + outerExtent / 2);
      maxY = math.max(maxY, offset.dy.abs() + outerExtent / 2);
    }

    final size = Size(maxX * 2, maxY * 2);
    final centers = offsets
        .map(
          (offset) => Offset(
            size.width / 2 + offset.dx,
            size.height / 2 + offset.dy,
          ),
        )
        .toList();

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
              centers: centers,
              centerIndex: i,
              orbitRadius: orbitRadius,
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
    required List<Offset> centers,
    required int centerIndex,
    required double orbitRadius,
  }) {
    final center = Offset(
      canvasSize.width / 2 + offset.dx,
      canvasSize.height / 2 + offset.dy,
    );
    final bubbleRadius = _bubbleDiameter / 2;
    final expenseRadius = _expenseBubbleDiameter / 2;
    final expenseAngles = _computeExpenseAngles(
      participant: participant,
      centers: centers,
      centerIndex: centerIndex,
      orbitRadius: orbitRadius,
      bubbleRadius: bubbleRadius,
      expenseRadius: expenseRadius,
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
        expenseAngles: expenseAngles,
      ),
    );
  }

  List<double>? _computeExpenseAngles({
    required Participant participant,
    required List<Offset> centers,
    required int centerIndex,
    required double orbitRadius,
    required double bubbleRadius,
    required double expenseRadius,
  }) {
    final expenses = participant.expenses;
    if (expenses.isEmpty) {
      return const <double>[];
    }

    final neighbors = <Offset>[];
    final center = centers[centerIndex];
    for (var i = 0; i < centers.length; i++) {
      if (i == centerIndex) {
        continue;
      }
      neighbors.add(centers[i] - center);
    }

    if (neighbors.isEmpty) {
      return null;
    }

    final minSpacingAngle =
        2 * math.asin(math.min(1.0, expenseRadius / orbitRadius));
    final availableArcs = _availableAngleArcs(
      neighbors: neighbors,
      orbitRadius: orbitRadius,
      bubbleRadius: bubbleRadius,
      expenseRadius: expenseRadius,
      minSpacingAngle: minSpacingAngle,
    );

    if (availableArcs.isEmpty) {
      return null;
    }

    final angles = _distributeAngles(
      arcs: availableArcs,
      count: expenses.length,
      minSpacingAngle: minSpacingAngle,
    );

    if (angles.length != expenses.length) {
      return null;
    }

    angles.sort();
    return angles;
  }

  List<_AngleRange> _availableAngleArcs({
    required List<Offset> neighbors,
    required double orbitRadius,
    required double bubbleRadius,
    required double expenseRadius,
    required double minSpacingAngle,
  }) {
    const twoPi = math.pi * 2;
    final blocked = <_AngleRange>[];

    for (final neighbor in neighbors) {
      final distance = neighbor.distance;
      if (distance == 0) {
        return const <_AngleRange>[];
      }

      final theta = _normalizeAngle(math.atan2(neighbor.dy, neighbor.dx));
      final minDistance = bubbleRadius + expenseRadius;
      final denominator = 2 * distance * orbitRadius;
      if (denominator <= 0) {
        continue;
      }

      final numerator =
          distance * distance + orbitRadius * orbitRadius - minDistance * minDistance;
      var ratio = numerator / denominator;

      if (ratio >= 1) {
        continue;
      }

      if (ratio <= -1) {
        return const <_AngleRange>[];
      }

      final delta = math.acos(ratio) + minSpacingAngle / 2;
      final start = _normalizeAngle(theta - delta);
      final end = _normalizeAngle(theta + delta);

      if (end < start) {
        blocked.add(_AngleRange(start, twoPi));
        blocked.add(_AngleRange(0, end));
      } else {
        blocked.add(_AngleRange(start, end));
      }
    }

    if (blocked.isEmpty) {
      return [_AngleRange(0, twoPi)];
    }

    blocked.sort((a, b) => a.start.compareTo(b.start));
    final merged = <_AngleRange>[];
    for (final range in blocked) {
      if (merged.isEmpty) {
        merged.add(range);
        continue;
      }

      final last = merged.last;
      if (range.start <= last.end) {
        merged[merged.length - 1] =
            _AngleRange(last.start, math.max(last.end, range.end));
      } else {
        merged.add(range);
      }
    }

    var cursor = 0.0;
    final available = <_AngleRange>[];
    for (final range in merged) {
      if (range.start > cursor) {
        available.add(_AngleRange(cursor, range.start));
      }
      cursor = math.max(cursor, range.end);
      if (cursor >= twoPi) {
        cursor = twoPi;
        break;
      }
    }

    if (cursor < twoPi) {
      available.add(_AngleRange(cursor, twoPi));
    }

    return available
        .where((range) => range.span > 0.01)
        .map((range) => _AngleRange(range.start, math.min(range.end, twoPi)))
        .toList();
  }

  List<double> _distributeAngles({
    required List<_AngleRange> arcs,
    required int count,
    required double minSpacingAngle,
  }) {
    final angles = <double>[];
    if (count == 0) {
      return angles;
    }

    final margin = minSpacingAngle / 2;
    final sortedArcs = arcs.toList()
      ..sort((a, b) => b.span.compareTo(a.span));

    var remaining = count;
    for (final arc in sortedArcs) {
      if (remaining == 0) {
        break;
      }

      final span = arc.span;
      if (span <= 0) {
        continue;
      }

      final effectiveMargin = math.min(margin, span / 2);
      final availableSpan = span - effectiveMargin * 2;
      if (availableSpan <= 0) {
        continue;
      }

      final slotCount = math.min(
        remaining,
        math.max(1, (availableSpan / minSpacingAngle).floor() + 1),
      );
      if (slotCount <= 0) {
        continue;
      }

      final step = slotCount == 1 ? 0 : availableSpan / (slotCount - 1);
      for (var i = 0; i < slotCount && remaining > 0; i++) {
        final angle = arc.start + effectiveMargin + step * i;
        angles.add(_normalizeAngle(angle));
        remaining--;
      }
    }

    if (remaining > 0) {
      return const <double>[];
    }

    return angles;
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

  double _normalizeAngle(double angle) {
    const twoPi = math.pi * 2;
    var normalized = angle % twoPi;
    if (normalized < 0) {
      normalized += twoPi;
    }
    return normalized;
  }
}

class _AngleRange {
  const _AngleRange(this.start, this.end);

  final double start;
  final double end;

  double get span => end - start;
}

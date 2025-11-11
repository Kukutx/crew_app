import 'dart:math' as math;

import 'package:crew_app/features/expenses/data/member.dart';
import 'package:crew_app/features/expenses/widgets/member_bubble.dart';
import 'package:crew_app/features/expenses/widgets/bubble_constants.dart';
import 'package:flutter/material.dart';

class MemberBubbleCluster extends StatelessWidget {
  const MemberBubbleCluster({
    super.key,
    required this.members,
    required this.allMembers,
    required this.onMemberTap,
    required this.onExpenseTap,
  });

  final List<Member> members;
  final List<Member> allMembers;
  final ValueChanged<Member> onMemberTap;
  final void Function(Member, MemberExpense) onExpenseTap;

  // 导出给外部使用
  static double get bubbleDiameter => BubbleConstants.defaultBubbleDiameter;

  /// 计算泡泡集群的实际尺寸
  /// 返回集群的宽度和高度
  static Size calculateClusterSize(List<Member> members) {
    if (members.isEmpty) {
      return Size.zero;
    }

    // 按金额大小排序，金额大的在后面（会显示更大）
    final displayMembers = members.take(7).toList()
      ..sort((a, b) => a.totalPaid.compareTo(b.totalPaid));
    
    // 计算每个成员的泡泡大小（根据金额等级）
    final memberSizes = _calculateBubbleSizes(displayMembers);
    
    final offsets = _positionsForCount(displayMembers.length);
    
    // 使用最大泡泡尺寸来计算 outerExtent，确保所有泡泡都能完整显示
    final maxBubbleSize = memberSizes.values.reduce(math.max);
    // 使用最大可能的费用泡泡大小（基础大小 × 最大成员泡泡缩放 × 最大金额比例）
    final baseExpenseSize = BubbleConstants.defaultExpenseBubbleDiameter;
    final baseParentSize = BubbleConstants.defaultBubbleDiameter;
    final maxParentScaleFactor = maxBubbleSize / baseParentSize;
    final maxExpenseSize = baseExpenseSize * maxParentScaleFactor * BubbleConstants.maxExpenseSizeRatioForBounds;

    // 计算实际需要的尺寸，考虑费用泡泡可能超出成员泡泡的范围
    double maxX = 0;
    double maxY = 0;
    for (var i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final member = displayMembers[i];
      final bubbleSize = memberSizes[member] ?? BubbleConstants.defaultBubbleDiameter;
      // 使用每个泡泡的实际大小来计算边界，考虑最大可能的费用泡泡大小
      final bubbleParentScaleFactor = bubbleSize / baseParentSize;
      final bubbleMaxExpenseSize = baseExpenseSize * bubbleParentScaleFactor * BubbleConstants.maxExpenseSizeRatio;
      final bubbleOuterExtent = MemberBubble.outerExtent(
        bubbleDiameter: bubbleSize,
        expenseBubbleDiameter: bubbleMaxExpenseSize,
      );
      final bubbleMaxX = offset.dx.abs() + bubbleOuterExtent / 2;
      final bubbleMaxY = offset.dy.abs() + bubbleOuterExtent / 2;
      maxX = math.max(maxX, bubbleMaxX);
      maxY = math.max(maxY, bubbleMaxY);
    }
    
    // 添加安全边距，确保费用泡泡不会被裁剪
    // 使用更大的边距，因为费用泡泡可能在轨道上任意位置
    final safetyMargin = BubbleConstants.safetyMargin;
    return Size(
      math.max((maxX * 2) + safetyMargin, BubbleConstants.defaultBubbleDiameter * 3), // 最小尺寸保证
      math.max((maxY * 2) + safetyMargin, BubbleConstants.defaultBubbleDiameter * 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    // 按金额大小排序，金额大的在后面（会显示更大）
    final displayMembers = members.take(7).toList()
      ..sort((a, b) => a.totalPaid.compareTo(b.totalPaid));
    
    // 计算每个成员的泡泡大小（根据金额等级）
    final memberSizes = _calculateBubbleSizes(displayMembers);
    
    final offsets = _positionsForCount(displayMembers.length);
    
    // 使用最大泡泡尺寸来计算 outerExtent，确保所有泡泡都能完整显示
    final maxBubbleSize = memberSizes.values.reduce(math.max);
    // 使用最大可能的费用泡泡大小（基础大小 × 最大成员泡泡缩放 × 最大金额比例）
    final baseExpenseSize = BubbleConstants.defaultExpenseBubbleDiameter;
    final baseParentSize = BubbleConstants.defaultBubbleDiameter;
    final maxParentScaleFactor = maxBubbleSize / baseParentSize;
    final maxExpenseSize = baseExpenseSize * maxParentScaleFactor * BubbleConstants.maxExpenseSizeRatioForBounds;
    
    final outerExtent = MemberBubble.outerExtent(
      bubbleDiameter: maxBubbleSize,
      expenseBubbleDiameter: maxExpenseSize,
    );
    final expenseRadius = maxExpenseSize / 2;
    final orbitRadius = outerExtent / 2 - expenseRadius;

    // 计算实际需要的尺寸，考虑费用泡泡可能超出成员泡泡的范围
    double maxX = 0;
    double maxY = 0;
    for (var i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final member = displayMembers[i];
      final bubbleSize = memberSizes[member] ?? BubbleConstants.defaultBubbleDiameter;
      // 使用每个泡泡的实际大小来计算边界，考虑最大可能的费用泡泡大小
      final bubbleParentScaleFactor = bubbleSize / baseParentSize;
      final bubbleMaxExpenseSize = baseExpenseSize * bubbleParentScaleFactor * BubbleConstants.maxExpenseSizeRatio;
      final bubbleOuterExtent = MemberBubble.outerExtent(
        bubbleDiameter: bubbleSize,
        expenseBubbleDiameter: bubbleMaxExpenseSize,
      );
      final bubbleMaxX = offset.dx.abs() + bubbleOuterExtent / 2;
      final bubbleMaxY = offset.dy.abs() + bubbleOuterExtent / 2;
      maxX = math.max(maxX, bubbleMaxX);
      maxY = math.max(maxY, bubbleMaxY);
    }
    
    // 添加安全边距，确保费用泡泡不会被裁剪
    // 使用更大的边距，因为费用泡泡可能在轨道上任意位置
    final safetyMargin = BubbleConstants.safetyMargin;
    final size = Size(
      math.max((maxX * 2) + safetyMargin, BubbleConstants.defaultBubbleDiameter * 3), // 最小尺寸保证
      math.max((maxY * 2) + safetyMargin, BubbleConstants.defaultBubbleDiameter * 3),
    );
    // 计算中心点位置（已经考虑了安全边距）
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
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < displayMembers.length; i++)
            _buildMember(
              member: displayMembers[i],
              offset: offsets[i],
              canvasSize: size,
              extent: outerExtent,
              centers: centers,
              centerIndex: i,
              orbitRadius: orbitRadius,
              bubbleSize: memberSizes[displayMembers[i]] ?? BubbleConstants.defaultBubbleDiameter,
            ),
        ],
      ),
    );
  }

  Widget _buildMember({
    required Member member,
    required Offset offset,
    required Size canvasSize,
    required double extent,
    required List<Offset> centers,
    required int centerIndex,
    required double orbitRadius,
    required double bubbleSize,
  }) {
    final center = Offset(
      canvasSize.width / 2 + offset.dx,
      canvasSize.height / 2 + offset.dy,
    );
    final bubbleRadius = bubbleSize / 2;
    
    // 根据实际泡泡大小计算 outerExtent
    // 使用最大可能的费用泡泡大小（基础大小 × 成员泡泡缩放 × 最大金额比例）
    final baseExpenseSize = BubbleConstants.defaultExpenseBubbleDiameter;
    final baseParentSize = BubbleConstants.defaultBubbleDiameter;
    final parentScaleFactor = bubbleSize / baseParentSize;
    final maxExpenseSize = baseExpenseSize * parentScaleFactor * BubbleConstants.maxExpenseSizeRatio;
    final expenseRadius = maxExpenseSize / 2;
    
    final memberOuterExtent = MemberBubble.outerExtent(
      bubbleDiameter: bubbleSize,
      expenseBubbleDiameter: maxExpenseSize,
    );
    
    // 根据实际泡泡大小计算 orbitRadius
    // 使用与 MemberBubble 相同的 padding 常量
    final memberOrbitRadius = bubbleSize / 2 + BubbleConstants.expenseOrbitPadding;
    
    final expenseAngles = _computeExpenseAngles(
      member: member,
      centers: centers,
      centerIndex: centerIndex,
      orbitRadius: memberOrbitRadius,
      bubbleRadius: bubbleRadius,
      expenseRadius: expenseRadius,
    );

    return Positioned(
      left: center.dx - memberOuterExtent / 2,
      top: center.dy - memberOuterExtent / 2,
      width: memberOuterExtent,
      height: memberOuterExtent,
      child: MemberBubble(
        member: member,
        allMembers: allMembers,
        bubbleDiameter: bubbleSize,
        expenseBubbleDiameter: BubbleConstants.defaultExpenseBubbleDiameter,
        onTap: () => onMemberTap(member),
        onExpenseTap: (expense) => onExpenseTap(member, expense),
        expenseAngles: expenseAngles,
      ),
    );
  }

  List<double>? _computeExpenseAngles({
    required Member member,
    required List<Offset> centers,
    required int centerIndex,
    required double orbitRadius,
    required double bubbleRadius,
    required double expenseRadius,
  }) {
    final expenses = member.expenses;
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

    // 如果没有邻居，均匀分布费用泡泡
    if (neighbors.isEmpty) {
      return List.generate(
        expenses.length,
        (index) => (2 * math.pi / expenses.length) * index - math.pi / 2,
      );
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

    // 如果无法找到足够的空间，使用备用方案：均匀分布但避开最近的邻居
    if (angles.length != expenses.length) {
      // 备用方案：找到最近的邻居方向，避开它，在其他方向均匀分布
      if (neighbors.isNotEmpty) {
        final nearestNeighbor = neighbors.reduce(
          (a, b) => a.distance < b.distance ? a : b,
        );
        final avoidAngle = math.atan2(nearestNeighbor.dy, nearestNeighbor.dx);
        // 在避开最近邻居的区域均匀分布
        final startAngle = avoidAngle + math.pi / 3;
        return List.generate(
          expenses.length,
          (index) => startAngle + (2 * math.pi * 2 / 3 / expenses.length) * index,
        );
      }
      // 最后备用方案：完全均匀分布
      return List.generate(
        expenses.length,
        (index) => (2 * math.pi / expenses.length) * index - math.pi / 2,
      );
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

  static List<Offset> _positionsForCount(int count) {
    // 基础半径，根据成员数量动态调整，确保合理的间距
    final baseRadius = BubbleConstants.defaultBubbleDiameter * BubbleConstants.baseRadiusMultiplier;
    
    // 根据成员数量调整半径
    final radiusMultiplier = count <= 7
        ? BubbleConstants.radiusMultipliers[count] ?? BubbleConstants.defaultRadiusMultiplier
        : BubbleConstants.defaultRadiusMultiplier;
    final radius = count == 1 ? 0.0 : baseRadius * radiusMultiplier;

    switch (count) {
      case 1:
        return [Offset.zero];
      case 2:
        // 两个人：水平排列，间距适中
        return [
          Offset(-radius, 0),
          Offset(radius, 0),
        ];
      case 3:
        // 三个人：等边三角形排列，间距更均匀
        return [
          Offset(0, -radius * 0.9),
          Offset(-radius * 0.9 * 0.866, radius * 0.9 * 0.5), // cos(60°) ≈ 0.866, sin(60°) ≈ 0.5
          Offset(radius * 0.9 * 0.866, radius * 0.9 * 0.5),
        ];
      case 4:
        // 四个人：正方形排列，间距均匀
        return [
          Offset(0, -radius),
          Offset(-radius, 0),
          Offset(radius, 0),
          Offset(0, radius),
        ];
      case 5:
        // 五个人：中心1个，外围4个，间距更合理
        return [
          Offset.zero,
          Offset(-radius * 0.9, -radius * 0.3),
          Offset(radius * 0.9, -radius * 0.3),
          Offset(-radius * 0.6, radius * 0.8),
          Offset(radius * 0.6, radius * 0.8),
        ];
      case 6:
        // 六个人：环形排列，间距均匀
        return _ringPositions(6, radius, startAngle: -math.pi / 2);
      case 7:
        // 7个人：中心1个，外围6个，使用更大的半径确保不拥挤
        // 中心位置稍微偏移，让整体更平衡
        return [
          Offset(0, -radius * 0.15), // 中心稍微上移，给下方留空间
          ..._ringPositions(6, radius, startAngle: -math.pi / 2),
        ];
      default:
        // 超过7个也使用环形布局，但半径更大
        final extendedRadius = count > 7 ? radius * 1.2 : radius;
        return _ringPositions(count, extendedRadius, startAngle: -math.pi / 2);
    }
  }

  static List<Offset> _ringPositions(int count, double radius, {double startAngle = 0}) {
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

  /// 根据金额大小计算每个成员的泡泡大小
  /// 人数越少，大小差异越大
  static Map<Member, double> _calculateBubbleSizes(List<Member> members) {
    if (members.isEmpty) {
      return {};
    }

    final result = <Member, double>{};
    final baseSize = BubbleConstants.defaultBubbleDiameter;
    final count = members.length;
    
    // 根据人数确定最小值和最大值
    final sizeRatio = count <= 7 
        ? BubbleConstants.bubbleSizeRatios[count] 
        : BubbleConstants.defaultBubbleSizeRatio;
    final effectiveSizeRatio = sizeRatio ?? BubbleConstants.defaultBubbleSizeRatio;
    final minSizeRatio = effectiveSizeRatio.min;
    final maxSizeRatio = effectiveSizeRatio.max;
    
    final minSize = baseSize * minSizeRatio;
    final maxSize = baseSize * maxSizeRatio;
    final sizeRange = maxSize - minSize;

    // 按金额排序（从小到大）
    final sorted = List<Member>.from(members)
      ..sort((a, b) => a.totalPaid.compareTo(b.totalPaid));

    // 根据排名在最小值和最大值之间线性插值
    for (var i = 0; i < sorted.length; i++) {
      final member = sorted[i];
      
      if (count == 1) {
        // 只有1个人，使用基础大小
        result[member] = baseSize;
      } else {
        // 计算排名比例（0.0 到 1.0）
        final rankRatio = i / (count - 1);
        // 使用缓动函数（ease-out）使差异更自然
        final easedRatio = rankRatio * rankRatio;
        // 线性插值
        result[member] = minSize + sizeRange * easedRatio;
      }
    }

    return result;
  }

}

class _AngleRange {
  const _AngleRange(this.start, this.end);

  final double start;
  final double end;

  double get span => end - start;
}

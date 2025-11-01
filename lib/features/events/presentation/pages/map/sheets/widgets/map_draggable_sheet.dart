import 'dart:math' as math;

import 'package:flutter/material.dart';

class MapDraggableSheet extends StatelessWidget {
  const MapDraggableSheet({
    super.key,
    required this.childBuilder,
    this.minChildSize = 0.25,
    this.initialChildSize = 0.4,
    this.maxChildSize = 0.9,
    this.snapSizes,
  })  : assert(minChildSize > 0 && minChildSize <= 1),
        assert(initialChildSize > 0 && initialChildSize <= 1),
        assert(maxChildSize > 0 && maxChildSize <= 1),
        assert(minChildSize <= maxChildSize),
        assert(initialChildSize >= minChildSize && initialChildSize <= maxChildSize);

  final WidgetBuilder childBuilder;
  final double minChildSize;
  final double initialChildSize;
  final double maxChildSize;
  final List<double>? snapSizes;

  @override
  Widget build(BuildContext context) {
    final resolvedSnapSizes = _resolveSnapSizes();

    return DraggableScrollableActuator(
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: minChildSize,
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        snap: true,
        snapSizes: resolvedSnapSizes,
        builder: (context, scrollController) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              top: 12,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                childBuilder(context),
              ],
            ),
          );
        },
      ),
    );
  }

  List<double> _resolveSnapSizes() {
    final candidates = snapSizes ?? [minChildSize, initialChildSize, maxChildSize];
    if (candidates.isEmpty) {
      return [minChildSize, maxChildSize];
    }

    final sorted = List<double>.from(candidates)..sort();
    final result = <double>[];
    for (final value in sorted) {
      final clamped = value.clamp(minChildSize, maxChildSize);
      if (result.isEmpty || (result.last - clamped).abs() > 0.0001) {
        result.add(clamped.toDouble());
      }
    }

    if (result.length == 1) {
      final extra = math.max(minChildSize, math.min(initialChildSize, maxChildSize));
      if ((result.first - extra).abs() > 0.0001) {
        result.insert(0, extra);
      }
    }

    return result;
  }
}

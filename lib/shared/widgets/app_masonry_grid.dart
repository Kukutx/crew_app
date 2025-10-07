import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// A reusable wrapper around [MasonryGridView] with sensible defaults used
/// across the app for waterfall-style layouts.
class AppMasonryGrid extends StatelessWidget {
  const AppMasonryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      controller: controller,
      padding: padding,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      itemCount: itemCount,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemBuilder: itemBuilder,
    );
  }
}

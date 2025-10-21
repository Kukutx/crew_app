import 'package:flutter/material.dart';

import '../road_trip_editor_models.dart';

class RoadTripGalleryGrid extends StatelessWidget {
  const RoadTripGalleryGrid({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onSetCover,
  });

  final List<RoadTripGalleryItem> items;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onSetCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withValues(alpha: .2)),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            '还没有选择图片，点击下方按钮添加',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _GalleryTile(
          index: index,
          item: item,
          onRemove: () => onRemove(index),
          onSetCover: () => onSetCover(index),
        );
      },
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onSetCover,
  });

  final int index;
  final RoadTripGalleryItem item;
  final VoidCallback onRemove;
  final VoidCallback onSetCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onSetCover,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: colorScheme.surfaceContainerHighest,
              child: item.isFile
                  ? Image.file(item.file!, fit: BoxFit.cover)
                  : Image.network(item.url!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: index == 0
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceTint.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                index == 0 ? '封面' : '第 ${index + 1} 张',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: index == 0
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceTint.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  color: colorScheme.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
          if (index != 0)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceTint.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '设为封面',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

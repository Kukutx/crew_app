import 'package:flutter/material.dart';

import '../data/road_trip_editor_models.dart';
import 'road_trip_gallery_grid.dart';
import 'road_trip_section_card.dart';

class RoadTripGallerySection extends StatelessWidget {
  const RoadTripGallerySection({
    super.key,
    required this.items,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onSetCover,
  });

  final List<RoadTripGalleryItem> items;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final ValueChanged<int> onSetCover;

  @override
  Widget build(BuildContext context) {
    return RoadTripSectionCard(
      icon: Icons.photo_library_outlined,
      title: '旅程影像',
      subtitle: '可选择多张，首张默认为封面',
      children: [
        RoadTripGalleryGrid(
          items: items,
          onRemove: onRemoveImage,
          onSetCover: onSetCover,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onPickImages,
          icon: const Icon(Icons.collections_outlined),
          label: Text(items.isEmpty ? '选择图片' : '追加图片'),
        ),
      ],
    );
  }
}

import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/road_trip_editor_models.dart';

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
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.photo_library_outlined,
      title: loc.road_trip_gallery_section_title,
      subtitle: loc.road_trip_gallery_section_subtitle,
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
          label: Text(items.isEmpty
              ? loc.road_trip_gallery_select_images
              : loc.road_trip_gallery_add_more),
        ),
      ],
    );
  }
}

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
    final loc = AppLocalizations.of(context)!;

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
            loc.road_trip_gallery_empty_hint,
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
    final loc = AppLocalizations.of(context)!;
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
                index == 0
                    ? loc.road_trip_gallery_cover_label
                    : loc.road_trip_gallery_image_label(index + 1),
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
                  loc.road_trip_gallery_set_cover,
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

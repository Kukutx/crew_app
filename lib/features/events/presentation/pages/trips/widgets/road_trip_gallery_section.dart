import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
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
      headerTrailing: FilledButton.icon(
        onPressed: onPickImages,
        icon: const Icon(Icons.collections_outlined, size: 18),
        label: Text(
          items.isEmpty
              ? loc.road_trip_gallery_select_images
              : loc.road_trip_gallery_add_more,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      children: [
        RoadTripGalleryGrid(
          items: items,
          onPickImages: onPickImages,
          onRemove: onRemoveImage,
          onSetCover: onSetCover,
        ),
      ],
    );
  }
}

class RoadTripGalleryGrid extends StatelessWidget {
  const RoadTripGalleryGrid({
    super.key,
    required this.items,
    required this.onPickImages,
    required this.onRemove,
    required this.onSetCover,
  });

  final List<RoadTripGalleryItem> items;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onSetCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return InkWell(
        onTap: onPickImages,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 140.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Text(
              loc.road_trip_gallery_empty_hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        itemBuilder: (context, index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12.w),
            child: _GalleryTile(
              index: index,
              item: item,
              onRemove: () => onRemove(index),
              onSetCover: () => onSetCover(index),
            ),
          );
        },
      ),
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
    return SizedBox(
      width: 160.w,
      height: 140.h,
      child: GestureDetector(
        onTap: onSetCover,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: 160.w,
                height: 140.h,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: item.isFile
                    ? Image.file(
                        item.file!,
                        fit: BoxFit.cover,
                        width: 160.w,
                        height: 140.h,
                      )
                    : Image.network(
                        item.url!,
                        fit: BoxFit.cover,
                        width: 160.w,
                        height: 140.h,
                      ),
              ),
            ),
            Positioned(
              top: 6.h,
              left: 6.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: index == 0
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceTint.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(10.r),
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
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6.h,
              right: 6.w,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceTint.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.close,
                    color: colorScheme.onSurface,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
            if (index != 0)
              Positioned(
                bottom: 6.h,
                right: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceTint.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    loc.road_trip_gallery_set_cover,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 9.sp,
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

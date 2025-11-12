import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:crew_app/shared/theme/app_design_tokens.dart';
import 'package:crew_app/shared/theme/app_spacing.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 用于重新定位 marker 的位置信息底部窗口
class MarkerLocationInfoBottomSheet extends StatelessWidget {
  const MarkerLocationInfoBottomSheet({
    super.key,
    required this.addressFuture,
    required this.nearbyPlacesFuture,
    this.isLoading = false,
  });

  final Future<String?>? addressFuture;
  final Future<List<NearbyPlace>>? nearbyPlacesFuture;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesignTokens.radiusXL.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Container(
            margin: AppSpacing.only(
              top: AppDesignTokens.spacingMD,
              bottom: AppDesignTokens.spacingSM,
            ),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // 地址信息
          if (addressFuture != null)
            Padding(
              padding: AppSpacing.symmetric(
                horizontal: AppDesignTokens.spacingLG,
                vertical: AppDesignTokens.spacingSM,
              ),
              child: FutureBuilder<String?>(
                future: addressFuture,
                builder: (context, snapshot) {
                  if (isLoading || snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.primary,
                          size: AppDesignTokens.iconSizeSM.sp,
                        ),
                        SizedBox(width: AppDesignTokens.spacingMD.w),
                        Expanded(
                          child: Text(
                            loc.map_location_info_address_loading,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        SizedBox(
                          width: AppDesignTokens.spacingLG.w,
                          height: AppDesignTokens.spacingLG.h,
                          child: CircularProgressIndicator(
                            strokeWidth: AppDesignTokens.borderWidthThick,
                          ),
                        ),
                      ],
                    );
                  }

                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.error,
                          size: AppDesignTokens.iconSizeSM.sp,
                        ),
                        SizedBox(width: AppDesignTokens.spacingMD.w),
                        Expanded(
                          child: Text(
                            loc.map_location_info_address_unavailable,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final address = snapshot.data;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: theme.colorScheme.primary,
                        size: AppDesignTokens.iconSizeSM.sp,
                      ),
                      SizedBox(width: AppDesignTokens.spacingMD.w),
                      Expanded(
                        child: Text(
                          address != null
                              ? address.truncate(maxLength: 30)
                              : loc.map_location_info_address_unavailable,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          // 附近POI列表
          if (nearbyPlacesFuture != null)
            Flexible(
              child: _NearbyPlacesList(future: nearbyPlacesFuture!),
            ),
        ],
      ),
    );
  }
}

class _NearbyPlacesList extends ConsumerWidget {
  const _NearbyPlacesList({
    required this.future,
    this.onPlaceTap,
  });

  final Future<List<NearbyPlace>> future;
  final ValueChanged<NearbyPlace>? onPlaceTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<List<NearbyPlace>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: AppSpacing.all(AppDesignTokens.spacingLG),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: AppSpacing.all(AppDesignTokens.spacingLG),
            child: Text(
              loc.map_location_info_nearby_error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final places = snapshot.data ?? [];
        if (places.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: AppSpacing.only(
                left: AppDesignTokens.spacingLG,
                top: AppDesignTokens.spacingSM,
                right: AppDesignTokens.spacingLG,
                bottom: AppDesignTokens.spacingSM,
              ),
              child: Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
            ),
            SizedBox(
              height: 120.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.symmetric(
                  horizontal: AppDesignTokens.spacingLG,
                ),
                itemCount: places.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: AppDesignTokens.spacingSM.w),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return _NearbyPlaceCard(
                    place: place,
                    onTap: onPlaceTap,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NearbyPlaceCard extends ConsumerWidget {
  const _NearbyPlaceCard({
    required this.place,
    this.onTap,
  });

  final NearbyPlace place;
  final ValueChanged<NearbyPlace>? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectionState = ref.watch(mapSelectionControllerProvider);
    final isSelected = selectionState.draggingMarkerPosition != null &&
        place.location != null &&
        selectionState.draggingMarkerPosition!.latitude == place.location!.latitude &&
        selectionState.draggingMarkerPosition!.longitude == place.location!.longitude;

    return GestureDetector(
      onTap: () {
        if (place.location != null) {
          // 设置选中状态和呼吸效果
          final selectionController = ref.read(mapSelectionControllerProvider.notifier);
          selectionController.setDraggingMarker(
            place.location!,
            DraggingMarkerType.destination, // 使用 destination 类型，因为这是附近地点
          );
          
          // 调用外部回调（如果有）
          onTap?.call(place);
        }
      },
      child: Container(
        width: 200.w,
        padding: AppSpacing.all(AppDesignTokens.spacingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected
                ? AppDesignTokens.borderWidthMedium
                : AppDesignTokens.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: AppDesignTokens.iconSizeSM.sp,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: AppDesignTokens.spacingXS.w),
                Expanded(
                  child: Text(
                    place.displayName.truncate(maxLength: 30),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (place.formattedAddress != null) ...[
              SizedBox(height: AppDesignTokens.spacingXS.h),
              Text(
                place.formattedAddress!.truncate(maxLength: 30),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


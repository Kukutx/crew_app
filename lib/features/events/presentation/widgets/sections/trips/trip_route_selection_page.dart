import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/event_card_tile.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 路线选择页面（起始页）
class TripRouteSelectionPage extends StatelessWidget {
  const TripRouteSelectionPage({
    super.key,
    this.scrollCtrl,
    required this.onContinue,
    required this.departureTitle,
    required this.departureSubtitle,
    required this.destinationTitle,
    required this.destinationSubtitle,
    required this.onEditDeparture,
    required this.onEditDestination,
    this.onSearchDeparture,
    this.onSearchDestination,
    this.departurePosition,
    this.departureAddressFuture,
    this.departureNearbyFuture,
    this.destinationPosition,
    this.destinationAddressFuture,
    this.destinationNearbyFuture,
  });

  final ScrollController? scrollCtrl;
  final VoidCallback onContinue;
  final String departureTitle;
  final String departureSubtitle;
  final String destinationTitle;
  final String destinationSubtitle;
  final VoidCallback onEditDeparture;
  final VoidCallback onEditDestination;
  final VoidCallback? onSearchDeparture;
  final VoidCallback? onSearchDestination;
  final LatLng? departurePosition;
  final Future<String?>? departureAddressFuture;
  final Future<List<NearbyPlace>>? departureNearbyFuture;
  final LatLng? destinationPosition;
  final Future<String?>? destinationAddressFuture;
  final Future<List<NearbyPlace>>? destinationNearbyFuture;

  @override
  Widget build(BuildContext context) {
    // 直接使用 scrollCtrl，如果为 null 则不使用 controller
    // 让 DraggableScrollableSheet 的滚动控制器直接连接到这个 CustomScrollView
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverList.list(
            children: [
              EventCardTile(
                leading: const Icon(Icons.radio_button_checked),
                title: departureTitle,
                onTap: onEditDeparture,
                onLeadingTap: onSearchDeparture,
              ),
              SizedBox(height: 12.h),
              EventCardTile(
                leading: const Icon(Icons.place_outlined),
                title: destinationTitle,
                onTap: departurePosition != null ? onEditDestination : null,
                onLeadingTap: departurePosition != null ? onSearchDestination : null,
                enabled: departurePosition != null,
              ),
              SizedBox(height: 24.h),
              UnifiedNearbyPlacesList(
                startNearbyFuture: departureNearbyFuture,
                destinationNearbyFuture: destinationNearbyFuture,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 统一的附近地点列表
class UnifiedNearbyPlacesList extends StatelessWidget {
  const UnifiedNearbyPlacesList({
    super.key,
    this.startNearbyFuture,
    this.destinationNearbyFuture,
  });

  final Future<List<NearbyPlace>>? startNearbyFuture;
  final Future<List<NearbyPlace>>? destinationNearbyFuture;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // 如果两个future都不存在，不显示任何内容
    if (startNearbyFuture == null && destinationNearbyFuture == null) {
      return const SizedBox.shrink();
    }

    // 使用 Future.wait 等待所有future完成
    final futures = <Future<List<NearbyPlace>>>[];
    if (startNearbyFuture != null) {
      futures.add(startNearbyFuture!);
    }
    if (destinationNearbyFuture != null) {
      futures.add(destinationNearbyFuture!);
    }

    return FutureBuilder<List<List<NearbyPlace>>>(
      future: Future.wait(futures),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 56.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                loc.map_location_info_nearby_error,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }

        // 合并所有POI列表，去重（基于id）
        final allPlaces = <String, NearbyPlace>{};
        final results = snapshot.data ?? [];
        for (final placeList in results) {
          for (final place in placeList) {
            allPlaces[place.id] = place;
          }
        }

        final places = allPlaces.values.toList();

        if (places.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                loc.map_location_info_nearby_empty,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.map_location_info_nearby_title,
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(height: 8.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < places.length; i++) ...[
                  NearbyPlaceTile(place: places[i]),
                  if (i < places.length - 1) SizedBox(height: 8.h),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}


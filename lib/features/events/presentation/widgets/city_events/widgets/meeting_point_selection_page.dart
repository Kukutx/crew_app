import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/widgets/common/event_card_tile.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 集合点选择页面（起始页）
class MeetingPointSelectionPage extends StatelessWidget {
  const MeetingPointSelectionPage({
    super.key,
    this.scrollCtrl,
    required this.onContinue,
    required this.meetingPointTitle,
    required this.meetingPointSubtitle,
    required this.onEditMeetingPoint,
    this.onSearchMeetingPoint,
    this.meetingPointPosition,
    this.meetingPointAddressFuture,
    this.meetingPointNearbyFuture,
  });

  final ScrollController? scrollCtrl;
  final VoidCallback onContinue;
  final String meetingPointTitle;
  final String meetingPointSubtitle;
  final VoidCallback onEditMeetingPoint;
  final VoidCallback? onSearchMeetingPoint;
  final LatLng? meetingPointPosition;
  final Future<String?>? meetingPointAddressFuture;
  final Future<List<NearbyPlace>>? meetingPointNearbyFuture;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverList.list(
            children: [
              Text(
                loc.map_select_meeting_point_title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                loc.map_select_meeting_point_tip,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 24.h),
              EventCardTile(
                leading: const Icon(Icons.location_on_outlined),
                title: meetingPointTitle,
                subtitle: meetingPointSubtitle,
                onTap: onEditMeetingPoint,
                onLeadingTap: onSearchMeetingPoint,
              ),
              SizedBox(height: 24.h),
              if (meetingPointNearbyFuture != null)
                _NearbyPlacesList(
                  nearbyFuture: meetingPointNearbyFuture!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 附近地点列表
class _NearbyPlacesList extends StatelessWidget {
  const _NearbyPlacesList({
    required this.nearbyFuture,
  });

  final Future<List<NearbyPlace>> nearbyFuture;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder<List<NearbyPlace>>(
      future: nearbyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final places = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.map_location_info_nearby_title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            ...places.map((place) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: EventCardTile(
                  leading: Icon(
                    Icons.place_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  title: place.displayName,
                  subtitle: place.formattedAddress,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}


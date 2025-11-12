import 'package:crew_app/features/events/presentation/widgets/city_events/widgets/meeting_point_selection_page.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/trips/trip_route_selection_page.dart';
import 'package:crew_app/features/events/presentation/widgets/common/config/event_creation_config.dart';
import 'package:flutter/material.dart';

/// 位置选择页面工厂
class LocationSelectionPageFactory {
  /// 根据配置和数据构建位置选择页面
  static Widget build({
    required LocationSelectionMode mode,
    required LocationSelectionPageData data,
    ScrollController? scrollCtrl,
    required VoidCallback onContinue,
  }) {
    switch (mode) {
      case LocationSelectionMode.singlePoint:
        final location = data.firstLocation;
        return MeetingPointSelectionPage(
          scrollCtrl: scrollCtrl,
          onContinue: onContinue,
          meetingPointTitle: location.title,
          meetingPointSubtitle: location.subtitle,
          onEditMeetingPoint: location.onTap ?? () {},
          onSearchMeetingPoint: location.onSearch,
          meetingPointPosition: location.position,
          meetingPointAddressFuture: location.addressFuture,
          meetingPointNearbyFuture: location.nearbyFuture,
          onClearMeetingPoint: location.onClear,
        );

      case LocationSelectionMode.startAndDestination:
        final firstLoc = data.firstLocation;
        final secondLoc = data.secondLocation;
        return TripRouteSelectionPage(
          scrollCtrl: scrollCtrl,
          onContinue: onContinue,
          departureTitle: firstLoc.title,
          departureSubtitle: firstLoc.subtitle,
          destinationTitle: secondLoc?.title ?? '',
          destinationSubtitle: secondLoc?.subtitle ?? '',
          onEditDeparture: firstLoc.onTap ?? () {},
          onEditDestination: secondLoc?.onTap ?? () {},
          onSearchDeparture: firstLoc.onSearch,
          onSearchDestination: secondLoc?.onSearch,
          departurePosition: firstLoc.position,
          departureAddressFuture: firstLoc.addressFuture,
          departureNearbyFuture: firstLoc.nearbyFuture,
          destinationPosition: secondLoc?.position,
          destinationAddressFuture: secondLoc?.addressFuture,
          destinationNearbyFuture: secondLoc?.nearbyFuture,
          onClearDeparture: firstLoc.onClear,
          onClearDestination: secondLoc?.onClear,
        );
    }
  }
}


import 'dart:io';

import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:flutter/material.dart';

/// Immutable snapshot of the form state for the road trip editor.
class RoadTripEditorState extends EventEditorState {
  const RoadTripEditorState({
    super.dateRange,
    this.routeType = EventRouteType.roundTrip,
    super.pricingType = EventPricingType.free,
    super.tags = const <String>[],
    super.galleryItems = const <EventGalleryItem>[],
  });

  final EventRouteType routeType;

  RoadTripEditorState copyWith({
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    EventRouteType? routeType,
    EventPricingType? pricingType,
    List<String>? tags,
    List<EventGalleryItem>? galleryItems,
  }) {
    return RoadTripEditorState(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      routeType: routeType ?? this.routeType,
      pricingType: pricingType ?? this.pricingType,
      tags: tags ?? this.tags,
      galleryItems: galleryItems ?? this.galleryItems,
    );
  }
}

/// Value object used to send data to the API when the form is submitted.
class RoadTripDraft extends EventDraft {
  RoadTripDraft({
    super.id,
    required super.title,
    required super.dateRange,
    required this.startLocation,
    required this.endLocation,
    required this.meetingPoint,
    required this.isRoundTrip,
    required this.segments,
    required super.maxMembers,
    required super.isFree,
    super.pricePerPerson,
    required super.tags,
    required super.description,
    super.hostDisclaimer = '',
    super.galleryImages = const <File>[],
    super.existingImageUrls = const <String>[],
  });

  final String startLocation;
  final String endLocation;
  final String meetingPoint;
  final bool isRoundTrip;
  final List<EventWaypointSegment> segments;
  
  List<EventWaypointSegment> get forwardSegments =>
      segments.where((segment) => segment.direction == EventWaypointDirection.forward).toList();

  List<EventWaypointSegment> get returnSegments =>
      segments.where((segment) => segment.direction == EventWaypointDirection.returnTrip).toList();

  List<Map<String, dynamic>> toSegmentsPayload() {
    return segments.map((segment) => segment.toJson()).toList();
  }
}

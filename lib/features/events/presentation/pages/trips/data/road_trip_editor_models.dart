import 'dart:io';

import 'package:flutter/material.dart';

/// Immutable snapshot of the form state for the road trip editor.
class RoadTripEditorState {
  const RoadTripEditorState({
    this.dateRange,
    this.routeType = RoadTripRouteType.roundTrip,
    this.pricingType = RoadTripPricingType.free,
    this.tags = const <String>[],
    this.galleryItems = const <RoadTripGalleryItem>[],
  });

  final DateTimeRange? dateRange;
  final RoadTripRouteType routeType;
  final RoadTripPricingType pricingType;
  final List<String> tags;
  final List<RoadTripGalleryItem> galleryItems;

  RoadTripEditorState copyWith({
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    RoadTripRouteType? routeType,
    RoadTripPricingType? pricingType,
    List<String>? tags,
    List<RoadTripGalleryItem>? galleryItems,
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
class RoadTripDraft {
  RoadTripDraft({
    this.id,
    required this.title,
    required this.dateRange,
    required this.startLocation,
    required this.endLocation,
    required this.meetingPoint,
    required this.isRoundTrip,
    required this.segments,
    required this.maxMembers,
    required this.isFree,
    this.pricePerPerson,
    required this.tags,
    required this.description,
    this.hostDisclaimer = '',
    this.galleryImages = const <File>[],
    this.existingImageUrls = const <String>[],
  });

  final String? id;
  final String title;
  final DateTimeRange dateRange;
  final String startLocation;
  final String endLocation;
  final String meetingPoint;
  final bool isRoundTrip;
  final List<RoadTripWaypointSegment> segments;
  final int maxMembers;
  final bool isFree;
  final double? pricePerPerson;
  final List<String> tags;
  final String description;
  final String hostDisclaimer;
  final List<File> galleryImages;
  final List<String> existingImageUrls;

  File? get coverImage => galleryImages.isEmpty ? null : galleryImages.first;
  
  List<RoadTripWaypointSegment> get forwardSegments =>
      segments.where((segment) => segment.direction == RoadTripWaypointDirection.forward).toList();

  List<RoadTripWaypointSegment> get returnSegments =>
      segments.where((segment) => segment.direction == RoadTripWaypointDirection.returnTrip).toList();

  List<Map<String, dynamic>> toSegmentsPayload() {
    return segments
        .map(
          (segment) => {
            'coordinate': segment.coordinate,
            'direction': segment.direction == RoadTripWaypointDirection.returnTrip
                ? 'return'
                : 'forward',
            if (segment.order != null) 'order': segment.order,
          },
        )
        .toList();
  }
}

class RoadTripWaypointSegment {
  const RoadTripWaypointSegment({
    required this.coordinate,
    required this.direction,
    this.order,
  });

  final String coordinate; // 格式: "lat,lng"
  final RoadTripWaypointDirection direction;
  final int? order;
}

enum RoadTripWaypointDirection { forward, returnTrip }

class RoadTripGalleryItem {
  const RoadTripGalleryItem.file(this.file) : url = null;
  const RoadTripGalleryItem.network(this.url) : file = null;

  final File? file;
  final String? url;

  bool get isFile => file != null;
}

enum RoadTripRouteType { oneWay, roundTrip }

enum RoadTripPricingType { free, paid }

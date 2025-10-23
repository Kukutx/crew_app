import 'dart:io';

import 'package:flutter/material.dart';

/// Immutable snapshot of the form state for the road trip editor.
class RoadTripEditorState {
  const RoadTripEditorState({
    this.dateRange,
    this.routeType = RoadTripRouteType.roundTrip,
    this.pricingType = RoadTripPricingType.free,
    this.carType,
    this.waypoints = const <String>[],
    this.tags = const <String>[],
    this.galleryItems = const <RoadTripGalleryItem>[],
  });

  final DateTimeRange? dateRange;
  final RoadTripRouteType routeType;
  final RoadTripPricingType pricingType;
  final String? carType;
  final List<String> waypoints;
  final List<String> tags;
  final List<RoadTripGalleryItem> galleryItems;

  RoadTripEditorState copyWith({
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    RoadTripRouteType? routeType,
    RoadTripPricingType? pricingType,
    String? carType,
    bool clearCarType = false,
    List<String>? waypoints,
    List<String>? tags,
    List<RoadTripGalleryItem>? galleryItems,
  }) {
    return RoadTripEditorState(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      routeType: routeType ?? this.routeType,
      pricingType: pricingType ?? this.pricingType,
      carType: clearCarType ? null : (carType ?? this.carType),
      waypoints: waypoints ?? this.waypoints,
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
    required this.waypoints,
    required this.maxParticipants,
    required this.isFree,
    this.pricePerPerson,
    this.carType,
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
  final List<String> waypoints;
  final int maxParticipants;
  final bool isFree;
  final double? pricePerPerson;
  final String? carType;
  final List<String> tags;
  final String description;
  final String hostDisclaimer;
  final List<File> galleryImages;
  final List<String> existingImageUrls;

  File? get coverImage => galleryImages.isEmpty ? null : galleryImages.first;
}

class RoadTripGalleryItem {
  const RoadTripGalleryItem.file(this.file) : url = null;
  const RoadTripGalleryItem.network(this.url) : file = null;

  final File? file;
  final String? url;

  bool get isFile => file != null;
}

enum RoadTripRouteType { oneWay, roundTrip }

enum RoadTripPricingType { free, paid }

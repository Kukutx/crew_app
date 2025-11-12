import 'dart:io';

import 'package:crew_app/features/events/presentation/pages/trips/data/road_trip_editor_models.dart';
import 'package:flutter/material.dart';

/// Immutable snapshot of the form state for the city event editor.
class CityEventEditorState {
  const CityEventEditorState({
    this.dateRange,
    this.pricingType = RoadTripPricingType.free,
    this.tags = const <String>[],
    this.galleryItems = const <RoadTripGalleryItem>[],
  });

  final DateTimeRange? dateRange;
  final RoadTripPricingType pricingType;
  final List<String> tags;
  final List<RoadTripGalleryItem> galleryItems;

  CityEventEditorState copyWith({
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    RoadTripPricingType? pricingType,
    List<String>? tags,
    List<RoadTripGalleryItem>? galleryItems,
  }) {
    return CityEventEditorState(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      pricingType: pricingType ?? this.pricingType,
      tags: tags ?? this.tags,
      galleryItems: galleryItems ?? this.galleryItems,
    );
  }
}

/// Value object used to send data to the API when the form is submitted.
class CityEventDraft {
  CityEventDraft({
    this.id,
    required this.title,
    required this.dateRange,
    required this.meetingPoint,
    required this.maxParticipants,
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
  final String meetingPoint; // 集合点位置名称
  final int maxParticipants;
  final bool isFree;
  final double? pricePerPerson;
  final List<String> tags;
  final String description;
  final String hostDisclaimer;
  final List<File> galleryImages;
  final List<String> existingImageUrls;

  File? get coverImage => galleryImages.isEmpty ? null : galleryImages.first;
}


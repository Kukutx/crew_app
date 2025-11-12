import 'dart:io';

import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:flutter/material.dart';

/// Immutable snapshot of the form state for the city event editor.
class CityEventEditorState extends EventEditorState {
  const CityEventEditorState({
    super.dateRange,
    super.pricingType = EventPricingType.free,
    super.tags = const <String>[],
    super.galleryItems = const <EventGalleryItem>[],
  });

  CityEventEditorState copyWith({
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    EventPricingType? pricingType,
    List<String>? tags,
    List<EventGalleryItem>? galleryItems,
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
class CityEventDraft extends EventDraft {
  CityEventDraft({
    super.id,
    required super.title,
    required super.dateRange,
    required this.meetingPoint,
    required super.maxMembers,
    required super.isFree,
    super.pricePerPerson,
    required super.tags,
    required super.description,
    super.hostDisclaimer = '',
    super.galleryImages = const <File>[],
    super.existingImageUrls = const <String>[],
  });

  final String meetingPoint; // 集合点位置名称
}


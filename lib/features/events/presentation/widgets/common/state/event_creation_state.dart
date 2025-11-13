import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 事件创建基础状态
/// 
/// 包含所有事件类型共用的状态字段
class EventCreationBaseState {
  // ==== 基本信息 ====
  final String title;
  final DateTimeRange? dateRange;

  // ==== 团队/费用 ====
  final int maxMembers;
  final double? price;
  final EventPricingType pricingType;

  // ==== 偏好 ====
  final List<String> tags;

  // ==== 图集 ====
  final List<EventGalleryItem> galleryItems;

  // ==== 文案 ====
  final String story;
  final String disclaimer;

  // ==== 创建状态 ====
  final bool isCreating;

  const EventCreationBaseState({
    this.title = '',
    this.dateRange,
    this.maxMembers = 4,
    this.price,
    this.pricingType = EventPricingType.free,
    this.tags = const [],
    this.galleryItems = const [],
    this.story = '',
    this.disclaimer = '',
    this.isCreating = false,
  });

  EventCreationBaseState copyWith({
    String? title,
    DateTimeRange? dateRange,
    int? maxMembers,
    double? price,
    EventPricingType? pricingType,
    List<String>? tags,
    List<EventGalleryItem>? galleryItems,
    String? story,
    String? disclaimer,
    bool? isCreating,
  }) {
    return EventCreationBaseState(
      title: title ?? this.title,
      dateRange: dateRange ?? this.dateRange,
      maxMembers: maxMembers ?? this.maxMembers,
      price: price ?? this.price,
      pricingType: pricingType ?? this.pricingType,
      tags: tags ?? this.tags,
      galleryItems: galleryItems ?? this.galleryItems,
      story: story ?? this.story,
      disclaimer: disclaimer ?? this.disclaimer,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

/// 位置信息状态
class LocationState {
  final LatLng? position;
  final String? address;
  final Future<String?>? addressFuture;
  final Future<List<NearbyPlace>>? nearbyFuture;

  const LocationState({
    this.position,
    this.address,
    this.addressFuture,
    this.nearbyFuture,
  });

  LocationState copyWith({
    LatLng? position,
    String? address,
    Future<String?>? addressFuture,
    Future<List<NearbyPlace>>? nearbyFuture,
  }) {
    return LocationState(
      position: position ?? this.position,
      address: address ?? this.address,
      addressFuture: addressFuture ?? this.addressFuture,
      nearbyFuture: nearbyFuture ?? this.nearbyFuture,
    );
  }
}


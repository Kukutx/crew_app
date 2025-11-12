import 'dart:io';

import 'package:flutter/material.dart';

/// 事件定价类型
enum EventPricingType {
  free,  // 免费
  paid,  // 付费
}

/// 事件路线类型
enum EventRouteType {
  oneWay,    // 单程
  roundTrip, // 往返
}

/// 事件途经点方向
enum EventWaypointDirection {
  forward,    // 去程
  returnTrip, // 返程
}

/// 事件图片项（用于图集）
class EventGalleryItem {
  const EventGalleryItem.file(this.file) : url = null;
  const EventGalleryItem.network(this.url) : file = null;

  final File? file;
  final String? url;

  bool get isFile => file != null;
  bool get isNetwork => url != null;
}

/// 事件途经点片段（用于路线）
class EventWaypointSegment {
  const EventWaypointSegment({
    required this.coordinate,
    required this.direction,
    this.order,
  });

  final String coordinate; // 格式: "lat,lng"
  final EventWaypointDirection direction;
  final int? order;

  Map<String, dynamic> toJson() => {
        'coordinate': coordinate,
        'direction': direction == EventWaypointDirection.returnTrip ? 'return' : 'forward',
        if (order != null) 'order': order,
      };
}

/// 事件编辑器状态基类
abstract class EventEditorState {
  const EventEditorState({
    this.dateRange,
    this.pricingType = EventPricingType.free,
    this.tags = const <String>[],
    this.galleryItems = const <EventGalleryItem>[],
  });

  final DateTimeRange? dateRange;
  final EventPricingType pricingType;
  final List<String> tags;
  final List<EventGalleryItem> galleryItems;
}

/// 事件草稿基类（用于提交到API）
abstract class EventDraft {
  const EventDraft({
    this.id,
    required this.title,
    required this.dateRange,
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
  final int maxMembers;
  final bool isFree;
  final double? pricePerPerson;
  final List<String> tags;
  final String description;
  final String hostDisclaimer;
  final List<File> galleryImages;
  final List<String> existingImageUrls;

  File? get coverImage => galleryImages.isEmpty ? null : galleryImages.first;
}


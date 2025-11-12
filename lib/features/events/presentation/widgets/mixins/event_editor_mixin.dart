import 'dart:io';

import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

/// 事件编辑器 Mixin（提取共享逻辑）
mixin EventEditorMixin<T extends StatefulWidget> on State<T> {
  final ImagePicker _picker = ImagePicker();

  /// 图片选择和处理
  Future<List<EventGalleryItem>> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return const [];
      return picked.map((x) => EventGalleryItem.file(File(x.path))).toList();
    } on PlatformException {
      if (!mounted) return const [];
      final loc = AppLocalizations.of(context)!;
      _showSnack(loc.road_trip_image_picker_failed);
      return const [];
    }
  }

  /// 移除图片
  List<EventGalleryItem> removeGalleryItem(List<EventGalleryItem> items, int index) {
    if (index < 0 || index >= items.length) return items;
    return List<EventGalleryItem>.of(items)..removeAt(index);
  }

  /// 设置封面
  List<EventGalleryItem> setCoverImage(List<EventGalleryItem> items, int index) {
    if (index <= 0 || index >= items.length) return items;
    final updated = List<EventGalleryItem>.of(items);
    final item = updated.removeAt(index);
    updated.insert(0, item);
    return updated;
  }

  /// 标签管理
  List<String> addTag(List<String> tags, String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || tags.contains(trimmed)) return tags;
    return [...tags, trimmed];
  }

  /// 移除标签
  List<String> removeTag(List<String> tags, String tag) {
    return tags.where((t) => t != tag).toList();
  }

  /// 坐标验证
  bool isValidCoordinate(LatLng coordinate) {
    return coordinate.latitude >= -90 &&
        coordinate.latitude <= 90 &&
        coordinate.longitude >= -180 &&
        coordinate.longitude <= 180;
  }

  /// 验证所有坐标
  bool validateAllCoordinates(List<LatLng> coordinates) {
    return coordinates.every(isValidCoordinate);
  }

  /// 显示 SnackBar
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 显示成功消息
  void showSuccessMessage(String message) {
    _showSnack(message);
  }

  /// 显示错误消息
  void showErrorMessage(String message) {
    _showSnack(message);
  }

  /// 格式化坐标为字符串
  String formatCoordinate(LatLng latLng) {
    return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
  }

  /// 解析坐标字符串
  LatLng? parseCoordinate(String coordinate) {
    final parts = coordinate.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    if (!isValidCoordinate(LatLng(lat, lng))) return null;
    return LatLng(lat, lng);
  }
}


import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

/// 事件创建公共功能混入
/// 
/// 提供标签管理、图片管理、地址加载等公共方法
mixin EventCreationMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  
  // ===== 标签管理 =====
  
  /// 添加标签
  void addTag(String tag, List<String> tags, TextEditingController controller) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !tags.contains(trimmedTag)) {
      setState(() => tags.add(trimmedTag));
    }
    controller.clear();
  }
  
  /// 删除标签
  void removeTag(String tag, List<String> tags) {
    setState(() => tags.remove(tag));
  }
  
  // ===== 图片管理 =====
  
  /// 选择多张图片
  Future<List<EventGalleryItem>> pickMultipleImages() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return [];
      
      return picked.map((x) => EventGalleryItem.file(File(x.path))).toList();
    } on PlatformException {
      if (!mounted) return [];
      final loc = AppLocalizations.of(context)!;
      showSnackBar(loc.road_trip_image_picker_failed);
      return [];
    }
  }
  
  /// 删除图片
  List<EventGalleryItem> removeImage(int index, List<EventGalleryItem> items) {
    if (index < 0 || index >= items.length) return items;
    final updated = List<EventGalleryItem>.of(items)..removeAt(index);
    return updated;
  }
  
  /// 设置封面（将图片移到第一位）
  List<EventGalleryItem> setImageAsCover(int index, List<EventGalleryItem> items) {
    if (index <= 0 || index >= items.length) return items;
    final updated = List<EventGalleryItem>.of(items);
    final item = updated.removeAt(index);
    updated.insert(0, item);
    return updated;
  }
  
  // ===== 地址加载 =====
  
  /// 加载格式化地址
  Future<String?> loadFormattedAddress(LatLng latLng) async {
    try {
      final locationManager = ref.read(locationSelectionManagerProvider);
      return await locationManager.reverseGeocode(latLng);
    } catch (e) {
      debugPrint('Failed to load address: $e');
      return null;
    }
  }
  
  /// 加载附近地点
  Future<List<NearbyPlace>> loadNearbyPlaces(LatLng latLng) async {
    try {
      final placesService = ref.read(placesServiceProvider);
      return await placesService.searchNearbyPlaces(
        latLng,
        maxResults: 10,
        radius: 200,
      );
    } catch (e) {
      debugPrint('Failed to load nearby places: $e');
      return [];
    }
  }
  
  // ===== 创建后清理 =====
  
  /// 清理地图选择状态
  void cleanupMapSelection() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.resetSelection();
    selectionController.setSelectionSheetOpen(false);
    selectionController.resetMapPadding();
  }
  
  /// 关闭 Overlay Sheet
  void closeOverlaySheet() {
    ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
  }
  
  /// 完整清理（创建完成后调用）
  void cleanupAfterCreation() {
    cleanupMapSelection();
    closeOverlaySheet();
  }
  
  // ===== UI 辅助方法 =====
  
  /// 显示 SnackBar
  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  /// 计算价格（根据定价类型）
  double? calculatePrice(EventPricingType pricingType, double? price) {
    return pricingType == EventPricingType.paid ? price : null;
  }
}


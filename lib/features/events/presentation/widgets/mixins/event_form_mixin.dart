import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_selection_controller.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/media_picker_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 事件表单通用功能 Mixin
/// 
/// 提供标签管理、图片管理、地址加载等公共方法
/// 统一了事件创建和编辑的共同逻辑
mixin EventFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // ===== 图片管理 =====

  /// 选择多张图片
  Future<List<EventGalleryItem>> pickImages() async {
    final files = await MediaPickerHelper.pickMultipleImages(
      config: const MediaPickerConfig(imageQuality: 80),
    );
    
    if (files.isEmpty) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        showSnackBar(loc.road_trip_image_picker_failed);
      }
      return [];
    }

    return files.map((file) => EventGalleryItem.file(file)).toList();
  }

  /// 移除图片
  List<EventGalleryItem> removeImage(int index, List<EventGalleryItem> items) {
    if (index < 0 || index >= items.length) return items;
    return List<EventGalleryItem>.of(items)..removeAt(index);
  }

  /// 设置封面（将图片移到第一位）
  List<EventGalleryItem> setImageAsCover(int index, List<EventGalleryItem> items) {
    if (index <= 0 || index >= items.length) return items;
    final updated = List<EventGalleryItem>.of(items);
    final item = updated.removeAt(index);
    updated.insert(0, item);
    return updated;
  }

  // ===== 标签管理 =====

  /// 添加标签
  List<String> addTag(String tag, List<String> tags) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || tags.contains(trimmed)) return tags;
    return [...tags, trimmed];
  }

  /// 删除标签
  List<String> removeTag(String tag, List<String> tags) {
    return tags.where((t) => t != tag).toList();
  }

  // ===== 坐标验证 =====

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

  /// 显示成功消息
  void showSuccessMessage(String message) {
    showSnackBar(message);
  }

  /// 显示错误消息
  void showErrorMessage(String message) {
    showSnackBar(message);
  }

  /// 计算价格（根据定价类型）
  double? calculatePrice(EventPricingType pricingType, double? price) {
    return pricingType == EventPricingType.paid ? price : null;
  }
}


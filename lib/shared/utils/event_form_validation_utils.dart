import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 事件表单验证工具类
class EventFormValidationHelper {
  EventFormValidationHelper._();

  /// 验证标题
  /// 
  /// 返回错误消息，如果验证通过返回 null
  static String? validateTitle(String title, {int maxLength = 20}) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return '请填写标题';
    }
    if (trimmed.length > maxLength) {
      return '标题不能超过$maxLength个字符';
    }
    return null;
  }

  /// 验证价格
  /// 
  /// 返回错误消息，如果验证通过返回 null
  static String? validatePrice(
    double? price,
    EventPricingType pricingType, {
    double minPrice = 0,
    double maxPrice = 100,
  }) {
    if (pricingType == EventPricingType.paid) {
      if (price == null) {
        return '请输入价格';
      }
      if (price < minPrice || price > maxPrice) {
        return '请输入有效的人均费用（$minPrice-$maxPrice）';
      }
    }
    return null;
  }

  /// 验证坐标是否在有效范围内
  static bool isValidCoordinate(LatLng coordinate) {
    return coordinate.latitude >= -90 &&
        coordinate.latitude <= 90 &&
        coordinate.longitude >= -180 &&
        coordinate.longitude <= 180;
  }

  /// 验证坐标
  /// 
  /// 返回错误消息，如果验证通过返回 null
  static String? validateCoordinate(LatLng? coordinate, {String label = '位置'}) {
    if (coordinate == null) {
      return '请选择$label';
    }
    if (!isValidCoordinate(coordinate)) {
      return '$label坐标值无效，请重新选择位置';
    }
    return null;
  }

  /// 验证途经点坐标列表
  /// 
  /// 返回错误消息，如果验证通过返回 null
  static String? validateWaypoints(List<LatLng> waypoints) {
    for (final wp in waypoints) {
      if (!isValidCoordinate(wp)) {
        return '坐标值无效，请重新选择位置';
      }
    }
    return null;
  }

  /// 验证基本信息（标题和日期范围）
  /// 
  /// 返回错误消息，如果验证通过返回 null
  static String? validateBasicInfo(String title, DateTimeRange? dateRange) {
    final titleError = validateTitle(title);
    if (titleError != null) {
      return titleError;
    }
    if (dateRange == null) {
      return '请选择日期范围';
    }
    return null;
  }

  /// 验证完整表单（通用）
  /// 
  /// 返回错误消息列表，如果验证通过返回空列表
  static List<String> validateCommonForm({
    required String title,
    required DateTimeRange? dateRange,
    required EventPricingType pricingType,
    double? price,
  }) {
    final errors = <String>[];

    // 验证基本信息
    final basicError = validateBasicInfo(title, dateRange);
    if (basicError != null) {
      errors.add(basicError);
    }

    // 验证价格
    final priceError = validatePrice(price, pricingType);
    if (priceError != null) {
      errors.add(priceError);
    }

    return errors;
  }

  /// 验证 Road Trip 表单
  /// 
  /// 返回错误消息列表，如果验证通过返回空列表
  static List<String> validateRoadTripForm({
    required String title,
    required DateTimeRange? dateRange,
    required LatLng? startLatLng,
    required LatLng? destinationLatLng,
    required List<LatLng> forwardWaypoints,
    required List<LatLng> returnWaypoints,
    required EventPricingType pricingType,
    double? price,
  }) {
    final errors = validateCommonForm(
      title: title,
      dateRange: dateRange,
      pricingType: pricingType,
      price: price,
    );

    // 验证起点
    final startError = validateCoordinate(startLatLng, label: '起点');
    if (startError != null) {
      errors.add(startError);
    }

    // 验证终点
    final destinationError = validateCoordinate(destinationLatLng, label: '终点');
    if (destinationError != null) {
      errors.add(destinationError);
    }

    // 验证途经点
    final allWaypoints = [...forwardWaypoints, ...returnWaypoints];
    final waypointError = validateWaypoints(allWaypoints);
    if (waypointError != null) {
      errors.add(waypointError);
    }

    return errors;
  }

  /// 验证 City Event 表单
  /// 
  /// 返回错误消息列表，如果验证通过返回空列表
  static List<String> validateCityEventForm({
    required String title,
    required DateTimeRange? dateRange,
    required LatLng? meetingPointLatLng,
    required EventPricingType pricingType,
    double? price,
  }) {
    final errors = validateCommonForm(
      title: title,
      dateRange: dateRange,
      pricingType: pricingType,
      price: price,
    );

    // 验证集合点
    final meetingPointError = validateCoordinate(meetingPointLatLng, label: '集合点');
    if (meetingPointError != null) {
      errors.add(meetingPointError);
    }

    return errors;
  }
}


import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_providers.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/widgets/common/utils/event_creation_helpers.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/data/road_trip_editor_models.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/state/road_trip_form_state.dart';
import 'package:crew_app/features/events/state/events_api_service.dart';
import 'package:crew_app/shared/utils/event_form_validation_utils.dart' show EventFormValidationHelper;
import 'package:crew_app/shared/widgets/sheets/completion_sheet/completion_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 自驾游创建管理器
/// 
/// 统一管理创建逻辑
class RoadTripCreationManager {
  final WidgetRef ref;
  final RoadTripFormState state;
  final VoidCallback onStateChanged;
  final BuildContext context;

  RoadTripCreationManager({
    required this.ref,
    required this.state,
    required this.onStateChanged,
    required this.context,
  });

  /// 创建自驾游
  Future<void> createRoadTrip() async {
    if (!state.canCreate()) return;

    state.isCreating = true;
    onStateChanged();

    try {
      final title = state.titleController.text.trim();

      // 使用验证工具类进行验证
      final validationErrors = EventFormValidationHelper.validateRoadTripForm(
        title: title,
        dateRange: state.editorState.dateRange,
        startLatLng: state.startLatLng,
        destinationLatLng: state.destinationLatLng,
        forwardWaypoints: state.forwardWaypoints,
        returnWaypoints: state.returnWaypoints,
        pricingType: state.pricingType,
        price: state.price,
      );

      if (validationErrors.isNotEmpty) {
        _showSnackBar(validationErrors.first);
        state.isCreating = false;
        onStateChanged();
        return;
      }

      // 价格已经在验证工具类中验证，这里直接使用
      final price = state.pricingType == EventPricingType.paid ? state.price : null;

      final segments = EventCreationHelper.buildWaypointSegments(
        forwardWaypoints: state.forwardWaypoints,
        returnWaypoints: state.returnWaypoints,
        isRoundTrip: state.routeType == EventRouteType.roundTrip,
      );

      final draft = RoadTripDraft(
        title: title,
        dateRange: state.editorState.dateRange!,
        startLocation: state.startAddress ??
            EventCreationHelper.formatCoordinate(state.startLatLng!),
        endLocation: state.destinationAddress ??
            EventCreationHelper.formatCoordinate(state.destinationLatLng!),
        meetingPoint: state.startAddress ??
            EventCreationHelper.formatCoordinate(state.startLatLng!),
        isRoundTrip: state.routeType == EventRouteType.roundTrip,
        segments: segments,
        maxMembers: state.maxMembers,
        isFree: state.pricingType == EventPricingType.free,
        pricePerPerson: price,
        tags: List.of(state.tags),
        description: state.storyController.text.trim(),
        hostDisclaimer: state.disclaimerController.text.trim(),
        galleryImages: state.editorState.galleryItems
            .where((item) => item.file != null)
            .map((item) => item.file!)
            .toList(),
        existingImageUrls: state.editorState.galleryItems
            .where((item) => item.url != null)
            .map((item) => item.url!)
            .toList(),
      );

      // 调用API创建
      await ref.read(eventsApiServiceProvider).createRoadTrip(draft);

      state.isCreating = false;
      onStateChanged();

      // 清理所有地图选择状态
      _cleanupAfterCreation();

      // 显示完成页 sheet
      if (context.mounted) {
        await showCompletionSheet(
          context,
          isSuccess: true,
        );
      }
    } catch (e) {
      state.isCreating = false;
      onStateChanged();

      // 清理所有地图选择状态
      _cleanupAfterCreation();

      // 显示完成页 sheet
      if (context.mounted) {
        await showCompletionSheet(
          context,
          isSuccess: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// 清理创建后的状态
  void _cleanupAfterCreation() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.resetSelection();
    selectionController.setSelectionSheetOpen(false);
    selectionController.setPendingWaypoint(null);
    selectionController.resetMapPadding();

    ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
  }

  /// 显示提示消息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}


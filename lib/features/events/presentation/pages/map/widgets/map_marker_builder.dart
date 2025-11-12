// widgets/map_marker_builder.dart
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/markers_layer.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/event_carousel_manager.dart';

/// 地图标记构建器，统一管理所有 marker 的创建逻辑
class MapMarkerBuilder {
  MapMarkerBuilder({
    required this.ref,
    required this.eventsClusterManagerId,
  });

  final WidgetRef ref;
  final ClusterManagerId eventsClusterManagerId;

  /// 构建所有 markers
  Set<Marker> buildMarkers({
    required AsyncValue<List<Event>> events,
    required MapSelectionState selectionState,
    required MapController mapController,
    required EventCarouselManager carouselManager,
    required LocationSelectionManager locationSelectionManager,
  }) {
    final markers = <Marker>{};

    // 添加事件 markers
    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null ||
        selectionState.isSelectingDestination;
    
    if (!shouldHideEventMarkers) {
      final eventsMarkers = _buildEventMarkers(
        events: events,
        mapController: mapController,
        carouselManager: carouselManager,
      );
      markers.addAll(eventsMarkers);
    }

    // 添加选择位置 markers
    _addSelectionMarkers(
      markers: markers,
      selectionState: selectionState,
      locationSelectionManager: locationSelectionManager,
    );

    // 添加途经点 markers
    _addWaypointMarkers(
      markers: markers,
      selectionState: selectionState,
    );

    return markers;
  }

  /// 构建事件 markers
  Set<Marker> _buildEventMarkers({
    required AsyncValue<List<Event>> events,
    required MapController mapController,
    required EventCarouselManager carouselManager,
  }) {
    return events.when(
      loading: () => const <Marker>{},
      error: (_, _) => const <Marker>{},
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: (event) {
          mapController.focusOnEvent(event);
          carouselManager.showEventCard(event);
        },
        clusterManagerId: eventsClusterManagerId,
      ).markers,
    );
  }

  /// 添加选择位置 markers（起点和终点）
  void _addSelectionMarkers({
    required Set<Marker> markers,
    required MapSelectionState selectionState,
    required LocationSelectionManager locationSelectionManager,
  }) {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);

    // 起点 marker
    if (selectionState.selectedLatLng != null) {
      markers.add(_createDraggableMarker(
        markerId: const MarkerId('selected_location'),
        position: selectionState.selectedLatLng!,
        color: BitmapDescriptor.hueAzure,
        onTap: () {
          // 选择起点标记点，显示呼吸效果
          selectionController.setDraggingMarker(
            selectionState.selectedLatLng!,
            DraggingMarkerType.start,
          );
        },
      ));
    }

    // 终点 marker
    if (selectionState.destinationLatLng != null) {
      markers.add(_createDraggableMarker(
        markerId: const MarkerId('destination_location'),
        position: selectionState.destinationLatLng!,
        color: BitmapDescriptor.hueGreen,
        onTap: () {
          // 选择终点标记点，显示呼吸效果
          selectionController.setDraggingMarker(
            selectionState.destinationLatLng!,
            DraggingMarkerType.destination,
          );
        },
      ));
    }
  }

  /// 添加途经点 markers
  void _addWaypointMarkers({
    required Set<Marker> markers,
    required MapSelectionState selectionState,
  }) {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);

    // 去程途经点
    for (int i = 0; i < selectionState.forwardWaypoints.length; i++) {
      final waypoint = selectionState.forwardWaypoints[i];
      markers.add(_createDraggableMarker(
        markerId: MarkerId('forward_waypoint_$i'),
        position: waypoint,
        color: BitmapDescriptor.hueYellow,
        onTap: () {
          // 选择去程途经点标记点，显示呼吸效果
          selectionController.setDraggingMarker(
            waypoint,
            DraggingMarkerType.forwardWaypoint,
          );
        },
      ));
    }

    // 返程途经点
    for (int i = 0; i < selectionState.returnWaypoints.length; i++) {
      final waypoint = selectionState.returnWaypoints[i];
      markers.add(_createDraggableMarker(
        markerId: MarkerId('return_waypoint_$i'),
        position: waypoint,
        color: BitmapDescriptor.hueYellow,
        onTap: () {
          // 选择返程途经点标记点，显示呼吸效果
          selectionController.setDraggingMarker(
            waypoint,
            DraggingMarkerType.returnWaypoint,
          );
        },
      ));
    }
  }

  /// 创建 marker（已移除拖拽功能）
  Marker _createDraggableMarker({
    required MarkerId markerId,
    required LatLng position,
    required double color,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: markerId,
      position: position,
      draggable: false, // 已移除拖拽功能
      icon: BitmapDescriptor.defaultMarkerWithHue(color),
      onTap: onTap != null ? () => onTap() : null,
    );
  }
}


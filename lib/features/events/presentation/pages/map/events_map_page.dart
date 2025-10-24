import 'dart:async';
import 'dart:math' as math;

import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/quick_actions_drawer.dart';

import '../../../data/event.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/cluster_icon_builder.dart';
import 'widgets/event_cluster_item.dart';
import 'widgets/events_map_event_carousel.dart';
import 'state/events_map_search_controller.dart';
import 'state/map_selection_controller.dart';
import 'controllers/map_controller.dart';
import 'controllers/event_carousel_manager.dart';
import 'controllers/search_manager.dart';
import 'controllers/location_selection_manager.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProviderSubscription<Event?>? _mapFocusSubscription;
  ProviderSubscription<EventCarouselManager>? _carouselSubscription;
  bool _isDrawerOpen = false;
  ClusterManager<EventClusterItem>? _clusterManager;
  Set<Marker> _clusterMarkers = const <Marker>{};
  List<String> _clusterItemSignatures = const [];
  late final ClusterIconBuilder _clusterIconBuilder;

  @override
  void initState() {
    super.initState();
    _clusterIconBuilder = ClusterIconBuilder();
    _clusterManager = ClusterManager<EventClusterItem>(
      const [],
      _onClusterMarkersUpdated,
      markerBuilder: _buildClusterMarker,
    );
    _mapFocusSubscription = ref.listenManual(mapFocusEventProvider, (
      previous,
      next,
    ) {
      final event = next;
      if (event == null) {
        return;
      }
      final mapController = ref.read(mapControllerProvider);
      mapController.focusOnEvent(event);
      final carouselManager = ref.read(eventCarouselManagerProvider);
      carouselManager.showEventCard(event);
      ref.read(mapFocusEventProvider.notifier).state = null;
    });
    _carouselSubscription = ref.listenManual(
      eventCarouselManagerProvider,
      (_, manager) {
        if (!mounted) {
          return;
        }
        _updateBottomNavigation(!_isDrawerOpen && !manager.isVisible);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateBottomNavigation(true);
    });
  }

  @override
  void dispose() {
    _clusterManager?.dispose();
    _mapFocusSubscription?.close();
    _carouselSubscription?.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(bottomNavigationVisibilityProvider.notifier);
      if (controller.state) {
        controller.state = false;
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    
    // 获取各个管理器
    final mapController = ref.watch(mapControllerProvider);
    final carouselManager = ref.watch(eventCarouselManagerProvider);
    final searchManager = ref.watch(searchManagerProvider);
    final locationSelectionManager = ref.watch(locationSelectionManagerProvider);
    
    final cardVisible = carouselManager.isVisible && carouselManager.events.isNotEmpty;
    final bottomPadding = (cardVisible ? 240 : 120) + safeBottom;
    final searchState = ref.watch(eventsMapSearchControllerProvider);
    final loc = AppLocalizations.of(context)!;
    
    final events = ref.watch(eventsProvider);
    final startCenter = mapController.getInitialCenter();
    final selectionState = ref.watch(mapSelectionControllerProvider);

    final markersLayer = events.when(
      loading: () => const MarkersLayer.empty(),
      error: (_, _) => const MarkersLayer.empty(),
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: (event) {
          mapController.focusOnEvent(event);
          carouselManager.showEventCard(event);
        },
      ),
    );

    _updateClusterItems(markersLayer.clusterItems);

    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null || selectionState.isSelectingDestination;
    final markers = <Marker>{
      if (!shouldHideEventMarkers) ..._clusterMarkers,
    };
    final selected = selectionState.selectedLatLng;
    if (selected != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: selected,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () => unawaited(locationSelectionManager.clearSelectedLocation()),
          onDrag: (pos) => ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(pos),
          onDragEnd: (pos) {
            ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(pos);
            HapticFeedback.lightImpact();
          },
        ),
      );
    }

    final destination = selectionState.destinationLatLng;
    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination_location'),
          position: destination,
          draggable: false,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          onTap: () => unawaited(locationSelectionManager.clearSelectedLocation()),
        ),
      );
    }

    // 页面首帧跳转至选中事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedEvent != null && !mapController.movedToSelected) {
        mapController.focusOnEvent(widget.selectedEvent!);
        carouselManager.showEventCard(widget.selectedEvent!);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      drawer: MapQuickActionsDrawer(
        onClose: () => Navigator.of(context).pop(),
      ),
      onDrawerChanged: (isOpened) {
        _isDrawerOpen = isOpened;
        _updateBottomNavigation(!isOpened && !carouselManager.isVisible);
      },
      appBar: SearchEventAppBar(
        controller: searchManager.searchController,
        focusNode: searchManager.searchFocusNode,
        onSearch: searchManager.onSearchSubmitted,
        onChanged: searchManager.onQueryChanged,
        onClear: searchManager.clearSearch,
        onQuickActionsTap: _openQuickActionsDrawer,
        onAvatarTap: _onAvatarTap,
        onResultTap: (event) => searchManager.onSearchResultTap(event, context),
        showResults: searchState.showResults,
        isLoading: searchState.isLoading,
        results: searchState.results,
        errorText: searchState.errorText,
        showClearSelectionAction: selectionState.selectedLatLng != null,
        onClearSelection: selectionState.selectedLatLng != null
            ? () => unawaited(locationSelectionManager.clearSelectedLocation())
            : null,
      ),
      body: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => searchManager.onOutsideTap(),
            child: MapCanvas(
              initialCenter: startCenter,
              onMapCreated: mapController.onMapCreated,
              onMapReady: mapController.onMapReady,
              onTap: (pos) {
                carouselManager.hideEventCard();
                unawaited(locationSelectionManager.onMapTap(pos, context));
              },
              onLongPress: (pos) {
                carouselManager.hideEventCard();
                unawaited(locationSelectionManager.onMapLongPress(pos, context));
              },
              onCameraMove: (position) {
                _clusterManager?.onCameraMove(position);
              },
              onCameraIdle: () {
                _clusterManager?.updateMap();
              },
              markers: markers,
              showUserLocation: true,
              showMyLocationButton: true,
              mapPadding: selectionState.mapPadding,
            ),
          ),
          EventsMapEventCarousel(
            events: carouselManager.events,
            visible: carouselManager.isVisible && carouselManager.events.isNotEmpty,
            controller: carouselManager.pageController,
            safeBottom: safeBottom,
            onPageChanged: carouselManager.onPageChanged,
            onOpenDetails: (event) => carouselManager.openEventDetails(event, context),
            onClose: carouselManager.hideEventCard,
            onRegister: () => _showSnackBar(loc.registration_not_implemented),
            onFavorite: () => _showSnackBar(loc.feature_not_ready),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FloatingActionButton(
              heroTag: 'events_map_add_fab',
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () => showCreateMomentSheet(context),
              child: const Icon(Icons.add),
            ),
          ),
          AppFloatingActionButton(
            heroTag: 'events_map_my_location_fab',
            margin: EdgeInsets.only(top: 12, bottom: bottomPadding, right: 6),
            onPressed: () async {
              await mapController.moveToMyLocation();
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }


  void _updateClusterItems(List<EventClusterItem> items) {
    final signatures = items
        .map(
          (item) =>
              '${item.event.id}_${item.event.latitude}_${item.event.longitude}',
        )
        .toList();
    if (listEquals(signatures, _clusterItemSignatures)) {
      return;
    }
    _clusterItemSignatures = signatures;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _clusterManager?.setItems(items);
      _clusterManager?.updateMap();
    });
  }

  void _onClusterMarkersUpdated(Set<Marker> markers) {
    if (!mounted) {
      return;
    }
    setState(() {
      _clusterMarkers = markers;
    });
  }

  Future<Marker> _buildClusterMarker(Cluster<EventClusterItem> cluster) async {
    if (cluster.isCluster) {
      final colorScheme = Theme.of(context).colorScheme;
      final icon = await _clusterIconBuilder.build(
        count: cluster.count,
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
      );
      return Marker(
        markerId: MarkerId('cluster_${cluster.getId()}'),
        position: cluster.location,
        icon: icon,
        onTap: () async {
          final controller = ref.read(mapControllerProvider).mapController;
          if (controller == null) {
            return;
          }
          final currentZoom = await controller.getZoomLevel();
          final targetZoom = math.min(currentZoom + 1.5, 18);
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, targetZoom),
          );
        },
      );
    }

    final item = cluster.items.first;
    final event = item.event;
    return Marker(
      markerId: MarkerId('event_${event.id}'),
      position: LatLng(event.latitude, event.longitude),
      infoWindow: InfoWindow(title: event.title, snippet: event.location),
      consumeTapEvents: true,
      onTap: item.triggerTap,
    );
  }


  void _openQuickActionsDrawer() {
    final searchManager = ref.read(searchManagerProvider);
    if (searchManager.searchFocusNode.hasFocus) {
      searchManager.searchFocusNode.unfocus();
    }
    final searchController = ref.read(eventsMapSearchControllerProvider.notifier);
    searchController.hideResults();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _updateBottomNavigation(bool visible) {
    final controller = ref.read(bottomNavigationVisibilityProvider.notifier);
    if (controller.state != visible) {
      controller.state = visible;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onAvatarTap(bool authed) {
    final searchManager = ref.read(searchManagerProvider);
    if (searchManager.searchFocusNode.hasFocus) {
      searchManager.searchFocusNode.unfocus();
    }
    ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
    if (!authed) {
      Navigator.of(context).pushNamed('/login');
      return;
    }
    ref.read(appOverlayIndexProvider.notifier).state = 2;
  }
}


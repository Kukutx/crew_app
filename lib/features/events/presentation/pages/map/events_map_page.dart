import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
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
import 'models/event_cluster_item.dart';
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
  ProviderSubscription<AsyncValue<List<Event>>>? _eventsSubscription;
  bool _isDrawerOpen = false;
  late final ClusterManager<EventClusterItem> _clusterManager;
  Set<Marker> _clusterMarkers = const <Marker>{};
  final Map<String, BitmapDescriptor> _clusterIconCache = <String, BitmapDescriptor>{};
  Color _clusterPrimaryColor = Colors.blue;
  Color _clusterTextColor = Colors.white;
  double _devicePixelRatio = 3;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _clusterManager = ClusterManager<EventClusterItem>(
      const <EventClusterItem>[],
      _onClusterMarkersUpdated,
      markerBuilder: _buildClusterMarker,
    );
    _eventsSubscription = ref.listenManual<AsyncValue<List<Event>>>(
      eventsProvider,
      (_, next) => _onEventsUpdated(next),
      fireImmediately: true,
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
    _mapFocusSubscription?.close();
    _carouselSubscription?.close();
    _eventsSubscription?.close();
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
    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.viewPadding.bottom;
    _clusterPrimaryColor = theme.colorScheme.primary;
    _clusterTextColor = theme.colorScheme.onPrimary;
    _devicePixelRatio = mediaQuery.devicePixelRatio;
    
    // 获取各个管理器
    final mapController = ref.watch(mapControllerProvider);
    final carouselManager = ref.watch(eventCarouselManagerProvider);
    final searchManager = ref.watch(searchManagerProvider);
    final locationSelectionManager = ref.watch(locationSelectionManagerProvider);
    
    final cardVisible = carouselManager.isVisible && carouselManager.events.isNotEmpty;
    final bottomPadding = (cardVisible ? 240 : 120) + safeBottom;
    final searchState = ref.watch(eventsMapSearchControllerProvider);
    final loc = AppLocalizations.of(context)!;
    
    final startCenter = mapController.getInitialCenter();
    final selectionState = ref.watch(mapSelectionControllerProvider);

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
              onMapCreated: _onMapCreated,
              onMapReady: _onMapReady,
              onTap: (pos) {
                carouselManager.hideEventCard();
                unawaited(locationSelectionManager.onMapTap(pos, context));
              },
              onLongPress: (pos) {
                carouselManager.hideEventCard();
                unawaited(locationSelectionManager.onMapLongPress(pos, context));
              },
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
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


  void _onEventsUpdated(AsyncValue<List<Event>> value) {
    value.whenOrNull(
      data: (events) {
        _clusterManager.setItems(events.map(EventClusterItem.new).toList());
        if (_isMapReady) {
          unawaited(_clusterManager.updateMap());
        }
      },
      error: (_, __) {
        _clusterManager.setItems(const <EventClusterItem>[]);
        _onClusterMarkersUpdated(const <Marker>{});
      },
    );
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
    if (cluster.isMultiple) {
      final icon = await _getClusterBitmap(cluster.count);
      final markerId = 'cluster_${cluster.location.latitude}_${cluster.location.longitude}_${cluster.count}';
      return Marker(
        markerId: MarkerId(markerId),
        position: cluster.location,
        icon: icon,
        consumeTapEvents: true,
        onTap: () => unawaited(_onClusterTap(cluster)),
      );
    }

    final Event event = cluster.items.first.event;
    return Marker(
      markerId: MarkerId('event_${event.id}'),
      position: cluster.location,
      infoWindow: InfoWindow(title: event.title, snippet: event.location),
      consumeTapEvents: true,
      onTap: () => _onEventMarkerTap(event),
    );
  }

  Future<BitmapDescriptor> _getClusterBitmap(int count) async {
    final key = '${_clusterPrimaryColor.value}_${_clusterTextColor.value}_${_devicePixelRatio}_$count';
    final cached = _clusterIconCache[key];
    if (cached != null) {
      return cached;
    }

    final double size = 56 * _devicePixelRatio;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Offset center = ui.Offset(size / 2, size / 2);
    final double radius = size / 2;

    final ui.Paint fillPaint = ui.Paint()..color = _clusterPrimaryColor;
    canvas.drawCircle(center, radius, fillPaint);

    final ui.Paint strokePaint = ui.Paint()
      ..color = _clusterPrimaryColor.withOpacity(0.75)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4 * _devicePixelRatio;
    canvas.drawCircle(center, radius - strokePaint.strokeWidth / 2, strokePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: _clusterTextColor,
          fontSize: 18 * _devicePixelRatio,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..layout();
    final ui.Offset textOffset = center - ui.Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }
    final bitmap = BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    _clusterIconCache[key] = bitmap;
    return bitmap;
  }

  Future<void> _onClusterTap(Cluster<EventClusterItem> cluster) async {
    final controller = ref.read(mapControllerProvider).mapController;
    if (controller == null) {
      return;
    }
    final double currentZoom = await controller.getZoomLevel();
    final double targetZoom = math.min(currentZoom + 2, 21);
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(cluster.location, targetZoom),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    ref.read(mapControllerProvider).onMapCreated(controller);
    _clusterManager.setMapId(controller.mapId);
  }

  void _onMapReady() {
    ref.read(mapControllerProvider).onMapReady();
    if (_isMapReady) {
      return;
    }
    _isMapReady = true;
    unawaited(_clusterManager.updateMap());
  }

  void _onCameraMove(CameraPosition position) {
    _clusterManager.onCameraMove(position);
  }

  Future<void> _onCameraIdle() async {
    if (!_isMapReady) {
      return;
    }
    await _clusterManager.updateMap();
  }

  void _onEventMarkerTap(Event event) {
    final mapController = ref.read(mapControllerProvider);
    unawaited(mapController.focusOnEvent(event));
    ref.read(eventCarouselManagerProvider).showEventCard(event);
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


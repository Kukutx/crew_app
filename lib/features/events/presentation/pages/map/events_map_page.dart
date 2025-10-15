import 'dart:async';
import 'dart:io';

import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/presentation/widgets/disclaimer_sheet.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/state/disclaimer_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/trips/create_road_trip_page.dart';

import '../../../data/event.dart';
import '../../../../../core/error/api_exception.dart';
import '../../../../../core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/events_map_event_carousel.dart';
import 'sheets/map_place_details_sheet.dart';
import '../detail/events_detail_page.dart';
import 'state/events_map_search_controller.dart';
import 'state/map_selection_controller.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  GoogleMapController? _map;
  bool _mapReady = false;
  bool _movedToSelected = false;
  late final PageController _eventCardController;
  bool _isEventCardVisible = false;
  List<Event> _carouselEvents = const <Event>[];
  bool _isHandlingLongPress = false;
  BuildContext? _selectionSheetContext;

  // 搜索框
  final _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  ProviderSubscription<Event?>? _mapFocusSubscription;

  @override
  void initState() {
    super.initState();
    _eventCardController = PageController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _mapFocusSubscription = ref.listenManual(mapFocusEventProvider, (
      previous,
      next,
    ) {
      final event = next;
      if (event == null) {
        return;
      }
      _focusOnEvent(event);
      ref.read(mapFocusEventProvider.notifier).state = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateBottomNavigation(true);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapFocusSubscription?.close();
    _eventCardController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(bottomNavigationVisibilityProvider.notifier);
      if (controller.state) {
        controller.state = false;
      }
    });
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final cardVisible = _isEventCardVisible && _carouselEvents.isNotEmpty;
    final bottomPadding = (cardVisible ? 240 : 120) + safeBottom;
    final searchState = ref.watch(eventsMapSearchControllerProvider);
    final loc = AppLocalizations.of(context)!;
    // 跟随定位（只在无选中事件时）
    ref.listen<AsyncValue<LatLng?>>(userLocationProvider, (prev, next) {
      final loc = next.value;
      if (!_movedToSelected && widget.selectedEvent == null && loc != null) {
        _moveCamera(loc, zoom: 14);
      }
    });

    final events = ref.watch(eventsProvider);
    final userLoc = ref.watch(userLocationProvider).value;
    final startCenter = userLoc ?? const LatLng(48.8566, 2.3522);
    final selectionState = ref.watch(mapSelectionControllerProvider);

    final markersLayer = events.when(
      loading: () => const MarkersLayer(markers: <Marker>{}),
      error: (_, _) => const MarkersLayer(markers: <Marker>{}),
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: _focusOnEvent,
      ),
    );

    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null || selectionState.isSelectingDestination;
    final markers = <Marker>{
      if (!shouldHideEventMarkers) ...markersLayer.markers,
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
          onTap: () => unawaited(_showLocationSelectionSheet()),
          onDrag: _onSelectedLocationDrag,
          onDragEnd: _onSelectedLocationDragEnd,
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
          onTap: () => unawaited(_showLocationSelectionSheet()),
        ),
      );
    }

    // 页面首帧跳转至选中事件,如果有选中事件，页面初始化时直接跳过去
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedEvent != null && !_movedToSelected) {
        _focusOnEvent(widget.selectedEvent!);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true, // 关键：让地图顶到状态栏
      appBar: SearchEventAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onSearch: _onSearchSubmitted,
        onChanged: _onQueryChanged,
        onClear: _onSearchClear,
        onCreateRoadTripTap: _onCreateRoadTripTap,
        onAvatarTap: _onAvatarTap,
        onResultTap: _onSearchResultTap,
        showResults: searchState.showResults,
        isLoading: searchState.isLoading,
        results: searchState.results,
        errorText: searchState.errorText,
        showClearSelectionAction: selectionState.selectedLatLng != null,
        onClearSelection: selectionState.selectedLatLng != null
            ? () => unawaited(_clearSelectedLocation())
            : null,
      ),
      body: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              } else {
                final state = ref.read(eventsMapSearchControllerProvider);
                if (state.showResults) {
                  ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
                }
              }
            },
            child: MapCanvas(
              initialCenter: startCenter,
              onMapCreated: _onMapCreated,
              onMapReady: _onMapReady,
              onTap: (pos) => unawaited(_onMapTap(pos)),
              onLongPress: (pos) => unawaited(_onMapLongPress(pos)),
              markers: markers,
              showUserLocation: true,
              showMyLocationButton: true,
              mapPadding: selectionState.mapPadding,
            ),
          ),
          EventsMapEventCarousel(
            events: _carouselEvents,
            visible: _isEventCardVisible && _carouselEvents.isNotEmpty,
            controller: _eventCardController,
            safeBottom: safeBottom,
            onPageChanged: _onEventCardPageChanged,
            onOpenDetails: _openEventDetails,
            onClose: _hideEventCard,
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
              final loc = ref.read(userLocationProvider).value;
              if (loc != null) {
                await _moveCamera(loc, zoom: 14);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Unable to get location")),
                );
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  void _onEventCardPageChanged(int index) {
    if (index < 0 || index >= _carouselEvents.length) {
      return;
    }
    final event = _carouselEvents[index];
    _moveCamera(LatLng(event.latitude, event.longitude), zoom: 14);
  }

  Future<void> _openEventDetails(Event event) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<Event>(
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
    if (!mounted) {
      return;
    }
    if (result != null) {
      _focusOnEvent(result);
    }
  }

  void _hideEventCard() {
    if (!_isEventCardVisible) {
      return;
    }
    setState(() {
      _isEventCardVisible = false;
      _carouselEvents = const <Event>[];
    });
    _updateBottomNavigation(true);
  }

  void _updateBottomNavigation(bool visible) {
    final controller = ref.read(bottomNavigationVisibilityProvider.notifier);
    if (controller.state != visible) {
      controller.state = visible;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _map?.dispose();
    _map = controller;
    _mapReady = false;
  }

  void _onMapReady() {
    if (_mapReady) {
      return;
    }
    _mapReady = true;
    final loc = ref.read(userLocationProvider).value;
    if (!_movedToSelected && loc != null) {
      _moveCamera(loc, zoom: 14);
    }
  }

  Future<void> _moveCamera(LatLng target, {double zoom = 14}) async {
    final controller = _map;
    if (controller == null) {
      return;
    }
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom, bearing: 0, tilt: 0),
        ),
      );
    } catch (_) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom, bearing: 0, tilt: 0),
        ),
      );
    }
  }

  Future<void> _onMapLongPress(LatLng latlng) async {
    if (!mounted) {
      return;
    }
    final selectionState = ref.read(mapSelectionControllerProvider);
    if (selectionState.isSelectingDestination) {
      await _handleDestinationSelection(latlng);
      return;
    }
    if (_isHandlingLongPress) {
      return;
    }
    _hideEventCard();
    _isHandlingLongPress = true;
    try {
      await _clearSelectedLocation();
      ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(latlng);
      await _moveCamera(latlng, zoom: 17);
      await _showLocationSelectionSheet();
    } finally {
      _isHandlingLongPress = false;
    }
  }

  Future<void> _handleDestinationSelection(LatLng position) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    if (!selectionState.isSelectingDestination ||
        selectionState.isSelectionSheetOpen) {
      return;
    }
    selectionController.setDestinationLatLng(position);
    await _moveCamera(position, zoom: 12);
    HapticFeedback.lightImpact();
    await _showDestinationSelectionSheet();
  }

  void _onSelectedLocationDrag(LatLng position) {
    ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(position);
  }

  void _onSelectedLocationDragEnd(LatLng position) {
    _onSelectedLocationDrag(position);
    HapticFeedback.lightImpact();
  }

  Future<void> _waitForSelectionSheetToClose() async {
    var attempts = 0;
    while (ref.read(mapSelectionControllerProvider).isSelectionSheetOpen &&
        attempts < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      attempts++;
    }
  }

  Future<void> _clearSelectedLocation({bool dismissSheet = true}) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);

    if (dismissSheet &&
        selectionState.isSelectionSheetOpen &&
        _selectionSheetContext != null) {
      Navigator.of(_selectionSheetContext!).pop(false);
      await _waitForSelectionSheetToClose();
    }

    selectionController.resetSelection();
  }

  Future<T?> _presentSelectionSheet<T>({
    required double expandedPadding,
    required Widget Function(
      BuildContext sheetContext,
      ValueNotifier<bool> collapsedNotifier,
    )
        builder,
  }) async {
    if (!mounted) {
      return null;
    }

    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final media = MediaQuery.of(context);
    final collapsedHeight = media.size.height * 0.15;
    final collapsedPadding = EdgeInsets.only(bottom: collapsedHeight);
    final expandedEdgeInsets = EdgeInsets.only(bottom: expandedPadding);
    final collapsedNotifier = ValueNotifier<bool>(false);

    void updatePadding() {
      if (!mounted) {
        return;
      }
      final isCollapsed = collapsedNotifier.value;
      selectionController
          .setMapPadding(isCollapsed ? collapsedPadding : expandedEdgeInsets);
    }

    selectionController.setSelectionSheetOpen(true);
    selectionController.setMapPadding(expandedEdgeInsets);

    collapsedNotifier.addListener(updatePadding);

    T? result;
    try {
      result = await Navigator.of(context).push<T>(
        PageRouteBuilder<T>(
          opaque: false,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (routeContext, animation, secondaryAnimation) {
            return _CollapsibleSheetRouteContent<T>(
              animation: animation,
              collapsedNotifier: collapsedNotifier,
              onBackgroundTap: () {
                collapsedNotifier.value = true;
              },
              builder: (sheetContext) {
                _selectionSheetContext = sheetContext;
                return builder(sheetContext, collapsedNotifier);
              },
            );
          },
        ),
      );
    } finally {
      collapsedNotifier.removeListener(updatePadding);
      collapsedNotifier.dispose();
      _selectionSheetContext = null;
      selectionController.resetMapPadding();
      selectionController.setSelectionSheetOpen(false);
    }

    return result;
  }

  Future<void> _showLocationSelectionSheet() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    if (!mounted ||
        selectionState.selectedLatLng == null ||
        selectionState.isSelectionSheetOpen) {
      return;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final paddingValue = 320.0 + bottomInset;

    final proceed = await _presentSelectionSheet<bool>(
      expandedPadding: paddingValue,
      builder: (sheetContext, collapsedNotifier) {
        return _StartLocationSheet(
          positionListenable: selectionController.selectedLatLngListenable,
          onConfirm: () => Navigator.of(sheetContext).pop(true),
          onCancel: () => Navigator.of(sheetContext).pop(false),
          reverseGeocode: _reverseGeocode,
          fetchNearbyPlaces: selectionController.getNearbyPlaces,
          collapsedListenable: collapsedNotifier,
          onExpand: () => collapsedNotifier.value = false,
        );
      },
    );

    if (proceed != null && proceed) {
      await _beginDestinationSelection();
    } else {
      await _clearSelectedLocation(dismissSheet: false);
    }
  }

  Future<void> _beginDestinationSelection() async {
    if (!mounted) {
      return;
    }
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    final start = selectionState.selectedLatLng;
    if (start == null) {
      await _clearSelectedLocation(dismissSheet: false);
      return;
    }

    selectionController.setSelectingDestination(true);
    selectionController.setDestinationLatLng(null);
    await _moveCamera(start, zoom: 6);
    final loc = AppLocalizations.of(context)!;
    _showSnackBar(loc.map_select_location_destination_tip);
  }

  Future<void> _showDestinationSelectionSheet() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    if (!mounted ||
        !selectionState.isSelectingDestination ||
        selectionState.selectedLatLng == null) {
      return;
    }
    if (selectionState.destinationLatLng == null) {
      return;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final paddingValue = 360.0 + bottomInset;

    final result = await _presentSelectionSheet<_QuickRoadTripResult>(
      expandedPadding: paddingValue,
      builder: (sheetContext, collapsedNotifier) {
        return _DestinationSelectionSheet(
          startPositionListenable: selectionController.selectedLatLngListenable,
          destinationListenable: selectionController.destinationLatLngListenable,
          reverseGeocode: _reverseGeocode,
          fetchNearbyPlaces: selectionController.getNearbyPlaces,
          collapsedListenable: collapsedNotifier,
          onExpand: () => collapsedNotifier.value = false,
          onCancel: () => Navigator.of(sheetContext).pop(null),
        );
      },
    );

    if (result == null) {
      await _finishDestinationFlow();
      return;
    }

    if (result.openDetailed) {
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateRoadTripPage(
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
      await _finishDestinationFlow();
      return;
    }

    if (result.destination != null) {
      await _createQuickRoadTrip(result);
    }
    await _finishDestinationFlow();
  }

  Future<void> _finishDestinationFlow() async {
    await _clearSelectedLocation(dismissSheet: false);
  }

  void _showEventCard(Event ev) {
    if (!mounted) {
      return;
    }
    final asyncEvents = ref.read(eventsProvider);
    final list = asyncEvents.maybeWhen(
      data: (events) => events,
      orElse: () => const <Event>[],
    );
    final selectedIndex = list.indexWhere((event) => event.id == ev.id);
    if (selectedIndex == -1) {
      setState(() {
        _carouselEvents = <Event>[ev];
        _isEventCardVisible = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_eventCardController.hasClients) {
          return;
        }
        _eventCardController.jumpToPage(0);
      });
      _updateBottomNavigation(false);
      return;
    }

    setState(() {
      _carouselEvents = list;
      _isEventCardVisible = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_eventCardController.hasClients) {
        return;
      }
      _eventCardController.jumpToPage(selectedIndex);
    });
    _updateBottomNavigation(false);
  }

  void _focusOnEvent(
    Event event, {
    bool showEventCard = true,
  }) {
    if (!mounted) {
      return;
    }
    _moveCamera(LatLng(event.latitude, event.longitude), zoom: 14);
    _movedToSelected = true;
    if (showEventCard) {
      _showEventCard(event);
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    if (!mounted) {
      return;
    }
    if (ref.read(mapSelectionControllerProvider).isSelectingDestination) {
      await _handleDestinationSelection(position);
      return;
    }
    _hideEventCard();
    final loc = AppLocalizations.of(context)!;
    final places = ref.read(placesServiceProvider);

    try {
      final placeId = await places.findPlaceId(position);
      if (!mounted) {
        return;
      }
      if (placeId == null) {
        await showMapPlaceDetailsSheet(
          context: context,
          detailsFuture: Future<PlaceDetails?>.value(null),
          emptyMessage: loc.map_place_details_not_found,
        );
        return;
      }

      await showMapPlaceDetailsSheet(
        context: context,
        detailsFuture: places.getPlaceDetails(placeId),
        emptyMessage: loc.map_place_details_not_found,
      );
    } on PlacesApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.contains('not configured')
          ? loc.map_place_details_missing_api_key
          : error.message;
      _showSnackBar(message.isEmpty ? loc.map_place_details_error : message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(loc.map_place_details_error);
    }
  }

  Future<void> _createQuickRoadTrip(_QuickRoadTripResult result) async {
    final destination = result.destination;
    if (destination == null) {
      return;
    }
    if (!await _ensureNetworkAvailable()) {
      return;
    }
    if (!await _ensureDisclaimerAccepted()) {
      return;
    }
    if (!mounted) {
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final title = result.title.trim();
    final startDisplay = _formatLocationDisplay(result.startAddress, result.start, loc);
    final destinationDisplay =
        _formatLocationDisplay(result.destinationAddress, destination, loc);

    try {
      await ref.read(eventsProvider.notifier).createEvent(
            title: title.isEmpty ? loc.map_quick_trip_default_title : title,
            description:
                loc.map_quick_trip_description(startDisplay, destinationDisplay),
            pos: result.start,
            locationName: '$startDisplay → $destinationDisplay',
          );
      _showSnackBar(loc.map_quick_trip_created);
    } on ApiException catch (error) {
      final message = error.message.isEmpty
          ? loc.map_quick_trip_create_failed
          : error.message;
      _showSnackBar(message);
    } catch (_) {
      _showSnackBar(loc.map_quick_trip_create_failed);
    }
  }

  Future<String?> _reverseGeocode(LatLng latlng) async {
    try {
      final list = await placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      ).timeout(const Duration(seconds: 5));
      if (list.isEmpty) {
        return null;
      }
      return _formatPlacemark(list.first);
    } catch (_) {
      return null;
    }
  }

  String _formatLocationDisplay(
    String? address,
    LatLng coords,
    AppLocalizations loc,
  ) {
    final trimmed = address?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return loc.location_coordinates(
      coords.latitude.toStringAsFixed(6),
      coords.longitude.toStringAsFixed(6),
    );
  }

  String? _formatPlacemark(Placemark place) {
    final parts = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
      place.country,
    ];
    final buffer = <String>[];
    final seen = <String>{};
    for (final part in parts) {
      if (part == null) {
        continue;
      }
      final trimmed = part.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) {
        continue;
      }
      buffer.add(trimmed);
    }
    if (buffer.isEmpty) {
      return null;
    }
    return buffer.join(', ');
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onCreateRoadTripTap() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
    ref.read(appOverlayIndexProvider.notifier).state = 0;
  }

  void _onAvatarTap(bool authed) {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
    if (!authed) {
      Navigator.of(context).pushNamed('/login');
      return;
    }
    ref.read(appOverlayIndexProvider.notifier).state = 2;
  }

  Future<bool> _ensureDisclaimerAccepted() async {
    final state = await ref.read(disclaimerStateProvider.future);
    if (!mounted) {
      return false;
    }
    if (!state.needsReconsent || state.toShow == null) {
      return true;
    }

    final accept = ref.read(acceptDisclaimerProvider);
    final acknowledged = await showDisclaimerBottomSheet(
      context: context,
      d: state.toShow!,
      onAccept: () => accept(state.toShow!.version),
    );

    return acknowledged;
  }

  Future<bool> _ensureNetworkAvailable() async {
    const offlineMessage = 'No internet connection detected.';
    final host = Uri.parse(Env.current).host;
    var lookupHost = host;

    if (lookupHost.isEmpty) {
      debugPrint(
        'Env.current host is empty; falling back to example.com for connectivity checks.',
      );
      lookupHost = 'example.com';
    }

    if (lookupHost.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(offlineMessage)));
      }
      return false;
    }

    try {
      final result = await InternetAddress.lookup(lookupHost);
      final hasConnection =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;

      if (!hasConnection && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(offlineMessage)));
      }

      return hasConnection;
    } on SocketException catch (error) {
      debugPrint('Network check failed for $lookupHost: $error');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(offlineMessage)));
      }
      return false;
    }
  }

  /// 搜索框事件
  void _onSearchFocusChanged() {
    final hasFocus = _searchFocusNode.hasFocus;
    final notifier = ref.read(eventsMapSearchControllerProvider.notifier);
    if (hasFocus) {
      notifier.onFocusChanged(true);
      final text = _searchController.text.trim();
      if (text.isEmpty) {
        return;
      }
      final state = ref.read(eventsMapSearchControllerProvider);
      if (state.query != text && !state.isLoading) {
        notifier.onQueryChanged(text);
      }
      return;
    }

    if (ref.read(mapSelectionControllerProvider).isSelectingDestination) {
      return;
    }

    notifier.onFocusChanged(false);
  }

  void _onQueryChanged(String raw) {
    ref.read(eventsMapSearchControllerProvider.notifier).onQueryChanged(raw);
  }

  void _onSearchSubmitted(String keyword) {
    ref.read(eventsMapSearchControllerProvider.notifier).onSubmitted(keyword);
  }

  void _onSearchClear() {
    _searchController.clear();
    ref.read(eventsMapSearchControllerProvider.notifier).clear();
  }

  void _onSearchResultTap(Event event) {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(eventsMapSearchControllerProvider.notifier);
    notifier.selectResult(event);
    _searchController.text = event.title;
    _focusOnEvent(event);
  }
}

class _CollapsibleSheetRouteContent<T> extends StatelessWidget {
  const _CollapsibleSheetRouteContent({
    required this.animation,
    required this.collapsedNotifier,
    required this.builder,
    required this.onBackgroundTap,
  });

  final Animation<double> animation;
  final ValueNotifier<bool> collapsedNotifier;
  final Widget Function(BuildContext context) builder;
  final VoidCallback onBackgroundTap;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(curved);

    final sheet = Builder(
      builder: builder,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: collapsedNotifier,
              builder: (context, collapsed, _) {
                return IgnorePointer(
                  ignoring: collapsed,
                  child: FadeTransition(
                    opacity: curved,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBackgroundTap,
                      child: Container(
                        color: collapsed
                            ? Colors.transparent
                            : Colors.black.withValues(alpha: .45),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: slide,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: collapsedNotifier,
                    builder: (context, collapsed, child) {
                      final height = MediaQuery.of(context).size.height;
                      final collapsedFactor = 0.15;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        constraints: BoxConstraints(
                          minHeight: collapsed ? height * 0.15 : 0,
                          maxHeight: height,
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: FractionallySizedBox(
                            heightFactor: collapsed ? collapsedFactor : null,
                            widthFactor: 1,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: sheet,
    );
  }
}

class _StartLocationSheet extends StatelessWidget {
  const _StartLocationSheet({
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
    required this.collapsedListenable,
    required this.onExpand,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ValueListenable<bool> collapsedListenable;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: collapsedListenable,
          builder: (context, collapsed, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: collapsed
                  ? _CollapsedSheetView(
                      key: const ValueKey('start_collapsed'),
                      title: AppLocalizations.of(context)!.map_select_location_title,
                      subtitle: AppLocalizations.of(context)!
                          .map_selection_sheet_tap_to_expand,
                      onExpand: onExpand,
                      onCancel: onCancel,
                    )
                  : _StartExpandedView(
                      key: const ValueKey('start_expanded'),
                      positionListenable: positionListenable,
                      onConfirm: onConfirm,
                      onCancel: onCancel,
                      reverseGeocode: reverseGeocode,
                      fetchNearbyPlaces: fetchNearbyPlaces,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _StartExpandedView extends StatelessWidget {
  const _StartExpandedView({
    super.key,
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tipStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.map_select_location_title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.map_select_location_tip,
                        style: tipStyle,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: loc.action_cancel,
                  onPressed: onCancel,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<LatLng?>(
              valueListenable: positionListenable,
              builder: (context, position, _) {
                if (position == null) {
                  return const SizedBox.shrink();
                }

                final coords = loc.location_coordinates(
                  position.latitude.toStringAsFixed(6),
                  position.longitude.toStringAsFixed(6),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            coords,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<String?>(
                      key: ValueKey(
                        '${position.latitude}_${position.longitude}_start_info',
                      ),
                      future: reverseGeocode(position),
                      builder: (context, snapshot) {
                        final icon = Icon(
                          Icons.home_outlined,
                          color: Colors.blueGrey.shade600,
                        );
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _LocationSheetRow(
                            icon: icon,
                            child: Text(loc.map_location_info_address_loading),
                          );
                        }
                        if (snapshot.hasError) {
                          return _LocationSheetRow(
                            icon: icon,
                            child: Text(loc.map_location_info_address_unavailable),
                          );
                        }
                        final address = snapshot.data;
                        final display = (address == null || address.trim().isEmpty)
                            ? loc.map_location_info_address_unavailable
                            : address;
                        return _LocationSheetRow(
                          icon: icon,
                          child: Text(display),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _NearbyPlacesPreview(
                      key: ValueKey(
                        '${position.latitude}_${position.longitude}_start_nearby',
                      ),
                      future: fetchNearbyPlaces(position),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: Text(loc.action_cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    child: Text(loc.map_location_info_create_event),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedSheetView extends StatelessWidget {
  const _CollapsedSheetView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onExpand,
    required this.onCancel,
  });

  final String title;
  final String subtitle;
  final VoidCallback onExpand;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return InkWell(
      onTap: onExpand,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          16,
          24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: subtitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: AppLocalizations.of(context)!.action_cancel,
                  onPressed: onCancel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: .12);
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _DestinationSelectionSheet extends StatefulWidget {
  const _DestinationSelectionSheet({
    required this.startPositionListenable,
    required this.destinationListenable,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
    required this.collapsedListenable,
    required this.onExpand,
    required this.onCancel,
  });

  final ValueListenable<LatLng?> startPositionListenable;
  final ValueListenable<LatLng?> destinationListenable;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ValueListenable<bool> collapsedListenable;
  final VoidCallback onExpand;
  final VoidCallback onCancel;

  @override
  State<_DestinationSelectionSheet> createState() =>
      _DestinationSelectionSheetState();
}

class _DestinationSelectionSheetState
    extends State<_DestinationSelectionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _titleController.addListener(_onTitleChanged);
    widget.destinationListenable.addListener(_onDestinationChanged);
  }

  @override
  void didUpdateWidget(covariant _DestinationSelectionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationListenable != widget.destinationListenable) {
      oldWidget.destinationListenable.removeListener(_onDestinationChanged);
      widget.destinationListenable.addListener(_onDestinationChanged);
    }
  }

  void _onDestinationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTitleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.destinationListenable.removeListener(_onDestinationChanged);
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  bool get _canCreate {
    return !_isSubmitting &&
        widget.destinationListenable.value != null &&
        _titleController.text.trim().isNotEmpty;
  }

  Future<void> _handleCreate() async {
    final loc = AppLocalizations.of(context)!;
    final destination = widget.destinationListenable.value;
    final start = widget.startPositionListenable.value;
    if (destination == null || start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.map_select_location_destination_missing)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      String? startAddress;
      String? destinationAddress;
      try {
        startAddress = await widget.reverseGeocode(start);
      } catch (_) {}
      try {
        destinationAddress = await widget.reverseGeocode(destination);
      } catch (_) {}
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        _QuickRoadTripResult(
          title: _titleController.text.trim(),
          start: start,
          destination: destination,
          startAddress: startAddress,
          destinationAddress: destinationAddress,
          openDetailed: false,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleOpenDetailed() async {
    final start = widget.startPositionListenable.value;
    if (start == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSubmitting = true);
    String? startAddress;
    String? destinationAddress;
    LatLng? destination;
    try {
      try {
        startAddress = await widget.reverseGeocode(start);
      } catch (_) {}
      destination = widget.destinationListenable.value;
      if (destination != null) {
        try {
          destinationAddress = await widget.reverseGeocode(destination);
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        _QuickRoadTripResult(
          title: _titleController.text.trim(),
          start: start,
          destination: destination,
          startAddress: startAddress,
          destinationAddress: destinationAddress,
          openDetailed: true,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.collapsedListenable,
          builder: (context, collapsed, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: collapsed
                  ? _DestinationCollapsedView(
                      key: const ValueKey('destination_collapsed'),
                      startListenable: widget.startPositionListenable,
                      destinationListenable: widget.destinationListenable,
                      onExpand: widget.onExpand,
                      onCancel: widget.onCancel,
                    )
                  : _DestinationExpandedView(
                      key: const ValueKey('destination_expanded'),
                      formKey: _formKey,
                      titleController: _titleController,
                      isSubmitting: _isSubmitting,
                      canCreate: _canCreate,
                      onCreate: _handleCreate,
                      onOpenDetailed: _handleOpenDetailed,
                      onCancel: widget.onCancel,
                      startListenable: widget.startPositionListenable,
                      destinationListenable: widget.destinationListenable,
                      reverseGeocode: widget.reverseGeocode,
                      fetchNearbyPlaces: widget.fetchNearbyPlaces,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _DestinationExpandedView extends StatelessWidget {
  const _DestinationExpandedView({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.isSubmitting,
    required this.canCreate,
    required this.onCreate,
    required this.onOpenDetailed,
    required this.onCancel,
    required this.startListenable,
    required this.destinationListenable,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final bool isSubmitting;
  final bool canCreate;
  final Future<void> Function() onCreate;
  final Future<void> Function() onOpenDetailed;
  final VoidCallback onCancel;
  final ValueListenable<LatLng?> startListenable;
  final ValueListenable<LatLng?> destinationListenable;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tipStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.map_select_location_title,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.map_select_location_tip,
                          style: tipStyle,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: loc.action_cancel,
                    onPressed: onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: loc.map_select_location_trip_title_label,
                  hintText: loc.map_select_location_trip_title_hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.map_select_location_title_required;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<LatLng?>(
                valueListenable: startListenable,
                builder: (context, position, _) {
                  if (position == null) {
                    return const SizedBox.shrink();
                  }

                  final coords = loc.location_coordinates(
                    position.latitude.toStringAsFixed(6),
                    position.longitude.toStringAsFixed(6),
                  );
                  final icon = Icon(
                    Icons.flag_circle_outlined,
                    color: theme.colorScheme.primary,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.map_select_location_start_label,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      _LocationSheetRow(
                        icon: icon,
                        child: Text(
                          coords,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<String?>(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_start',
                        ),
                        future: reverseGeocode(position),
                        builder: (context, snapshot) {
                          final addressIcon = Icon(
                            Icons.home_outlined,
                            color: Colors.blueGrey.shade600,
                          );
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_loading),
                            );
                          }
                          if (snapshot.hasError) {
                            return _LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_unavailable),
                            );
                          }
                          final address = snapshot.data;
                          final display = (address == null || address.trim().isEmpty)
                              ? loc.map_location_info_address_unavailable
                              : address;
                          return _LocationSheetRow(
                            icon: addressIcon,
                            child: Text(display),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _NearbyPlacesPreview(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_start_nearby_trip',
                        ),
                        future: fetchNearbyPlaces(position),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<LatLng?>(
                valueListenable: destinationListenable,
                builder: (context, position, _) {
                  final icon = Icon(
                    Icons.flag,
                    color: Colors.green.shade700,
                  );
                  final label = Text(
                    loc.map_select_location_destination_label,
                    style: theme.textTheme.labelLarge,
                  );
                  if (position == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label,
                        const SizedBox(height: 6),
                        _LocationSheetRow(
                          icon: icon,
                          child: Text(
                            loc.map_select_location_destination_tip,
                            style: tipStyle,
                          ),
                        ),
                      ],
                    );
                  }

                  final coords = loc.location_coordinates(
                    position.latitude.toStringAsFixed(6),
                    position.longitude.toStringAsFixed(6),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label,
                      const SizedBox(height: 6),
                      _LocationSheetRow(
                        icon: icon,
                        child: Text(
                          coords,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<String?>(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_destination',
                        ),
                        future: reverseGeocode(position),
                        builder: (context, snapshot) {
                          final addressIcon = Icon(
                            Icons.place_outlined,
                            color: Colors.green.shade700,
                          );
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_loading),
                            );
                          }
                          if (snapshot.hasError) {
                            return _LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_unavailable),
                            );
                          }
                          final address = snapshot.data;
                          final display = (address == null || address.trim().isEmpty)
                              ? loc.map_location_info_address_unavailable
                              : address;
                          return _LocationSheetRow(
                            icon: addressIcon,
                            child: Text(display),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _NearbyPlacesPreview(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_destination_nearby_trip',
                        ),
                        future: fetchNearbyPlaces(position),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: isSubmitting ? null : () => onOpenDetailed(),
                icon: const Icon(Icons.auto_awesome_motion_outlined),
                label: Text(loc.map_select_location_open_detailed),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting ? null : onCancel,
                      child: Text(loc.action_cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: canCreate ? () => onCreate() : null,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loc.map_select_location_create_trip),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationCollapsedView extends StatelessWidget {
  const _DestinationCollapsedView({
    super.key,
    required this.startListenable,
    required this.destinationListenable,
    required this.onExpand,
    required this.onCancel,
  });

  final ValueListenable<LatLng?> startListenable;
  final ValueListenable<LatLng?> destinationListenable;
  final VoidCallback onExpand;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return InkWell(
      onTap: onExpand,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          16,
          24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.map_select_location_create_trip,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.map_selection_sheet_tap_to_expand,
                        style: subtitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: loc.action_cancel,
                  onPressed: onCancel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<LatLng?>(
              valueListenable: startListenable,
              builder: (context, position, _) {
                if (position == null) {
                  return const SizedBox.shrink();
                }
                final coords = loc.location_coordinates(
                  position.latitude.toStringAsFixed(6),
                  position.longitude.toStringAsFixed(6),
                );
                return _LocationSheetRow(
                  icon: Icon(
                    Icons.flag_circle_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  child: Text(
                    coords,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<LatLng?>(
              valueListenable: destinationListenable,
              builder: (context, position, _) {
                final icon = Icon(
                  Icons.flag,
                  color: Colors.green.shade700,
                );
                if (position == null) {
                  return _LocationSheetRow(
                    icon: icon,
                    child: Text(
                      loc.map_select_location_destination_tip,
                      style: subtitleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                final coords = loc.location_coordinates(
                  position.latitude.toStringAsFixed(6),
                  position.longitude.toStringAsFixed(6),
                );
                return _LocationSheetRow(
                  icon: icon,
                  child: Text(
                    coords,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyPlacesPreview extends StatelessWidget {
  const _NearbyPlacesPreview({super.key, required this.future});

  final Future<List<NearbyPlace>> future;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.map_location_info_nearby_title,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<NearbyPlace>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              var message = loc.map_location_info_nearby_error;
              if (error is PlacesApiException &&
                  error.message.contains('not configured')) {
                message = loc.map_place_details_missing_api_key;
              }
              return Text(
                message,
                style: theme.textTheme.bodySmall,
              );
            }
            final places = snapshot.data;
            if (places == null || places.isEmpty) {
              return Text(
                loc.map_location_info_nearby_empty,
                style: theme.textTheme.bodySmall,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < places.length; i++) ...[
                  _NearbyPlaceTile(place: places[i]),
                  if (i < places.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NearbyPlaceTile extends StatelessWidget {
  const _NearbyPlaceTile({required this.place});

  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );
    final address = place.formattedAddress?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.place_outlined,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.displayName,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (address != null && address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
                  style: subtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationSheetRow extends StatelessWidget {
  const _LocationSheetRow({required this.icon, required this.child});

  final Icon icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}

class _QuickRoadTripResult {
  const _QuickRoadTripResult({
    required this.title,
    required this.start,
    required this.destination,
    required this.startAddress,
    required this.destinationAddress,
    required this.openDetailed,
  });

  final String title;
  final LatLng start;
  final LatLng? destination;
  final String? startAddress;
  final String? destinationAddress;
  final bool openDetailed;
}

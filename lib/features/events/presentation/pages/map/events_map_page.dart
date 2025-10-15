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
import '../../../../../core/network/api_service.dart';
import '../../../../../core/state/di/providers.dart';
import '../../../../../core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/map_event_floating_card.dart';
import 'sheets/map_create_event_sheet.dart';
import 'sheets/map_place_details_sheet.dart';
import '../detail/events_detail_page.dart';

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
  int _activeEventIndex = 0;
  LatLng? _selectedLatLng;
  LatLng? _destinationLatLng;
  late final ValueNotifier<LatLng?> _selectedLatLngNotifier;
  late final ValueNotifier<LatLng?> _destinationLatLngNotifier;
  bool _isHandlingLongPress = false;
  bool _isSelectingDestination = false;
  bool _isSelectionSheetOpen = false;
  EdgeInsets _mapPadding = EdgeInsets.zero;
  BuildContext? _selectionSheetContext;

  // 搜索框
  final _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  late final ApiService _api;
  List<Event> _searchResults = const <Event>[];
  bool _isSearching = false;
  bool _showSearchResults = false;
  String? _searchError;
  String _currentSearchQuery = '';
  Timer? _searchDebounce;
  ProviderSubscription<Event?>? _mapFocusSubscription;

  @override
  void initState() {
    super.initState();
    _api = ref.read(apiServiceProvider);
    _eventCardController = PageController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _selectedLatLngNotifier = ValueNotifier<LatLng?>(null);
    _destinationLatLngNotifier = ValueNotifier<LatLng?>(null);
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
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapFocusSubscription?.close();
    _eventCardController.dispose();
    _selectedLatLngNotifier.dispose();
    _destinationLatLngNotifier.dispose();
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

    final markersLayer = events.when(
      loading: () => const MarkersLayer(markers: <Marker>{}),
      error: (_, _) => const MarkersLayer(markers: <Marker>{}),
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: (event) => _focusOnEvent(event, showEventCard: false),
      ),
    );

    final markers = <Marker>{...markersLayer.markers};
    final selected = _selectedLatLng;
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

    final destination = _destinationLatLng;
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
        showResults: _showSearchResults,
        isLoading: _isSearching,
        results: _searchResults,
        errorText: _searchError,
        showClearSelectionAction: _selectedLatLng != null,
        onClearSelection:
            _selectedLatLng != null ? () => unawaited(_clearSelectedLocation()) : null,
      ),
      body: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              } else if (_showSearchResults) {
                setState(() => _showSearchResults = false);
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
              mapPadding: _mapPadding,
            ),
          ),
          _buildEventCardOverlay(safeBottom),
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

  Widget _buildEventCardOverlay(double safeBottom) {
    final loc = AppLocalizations.of(context)!;
    final visible = _isEventCardVisible && _carouselEvents.isNotEmpty;
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          offset: Offset(0, visible ? 0 : 1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            opacity: visible ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + safeBottom),
              child: SizedBox(
                height: 158,
                child: PageView.builder(
                  controller: _eventCardController,
                  physics: _carouselEvents.length > 1
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  onPageChanged: _onEventCardPageChanged,
                  itemCount: _carouselEvents.length,
                  itemBuilder: (_, index) {
                    final event = _carouselEvents[index];
                    return MapEventFloatingCard(
                      key: ValueKey(event.id),
                      event: event,
                      onTap: () => _openEventDetails(event),
                      onClose: _hideEventCard,
                      onRegister: () {
                        _showSnackBar(loc.registration_not_implemented);
                      },
                      onFavorite: () {
                        _showSnackBar(loc.feature_not_ready);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onEventCardPageChanged(int index) {
    if (index < 0 || index >= _carouselEvents.length) {
      return;
    }
    setState(() => _activeEventIndex = index);
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
      _activeEventIndex = 0;
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
    if (_isSelectingDestination) {
      _setDestinationLatLng(latlng);
      await _moveCamera(latlng, zoom: 12);
      HapticFeedback.lightImpact();
      return;
    }
    if (_isHandlingLongPress) {
      return;
    }
    _hideEventCard();
    _isHandlingLongPress = true;
    try {
      await _clearSelectedLocation();
      _setSelectedLatLng(latlng);
      await _moveCamera(latlng, zoom: 17);
      await _showLocationSelectionSheet();
    } finally {
      _isHandlingLongPress = false;
    }
  }

  void _setSelectedLatLng(LatLng? position) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLatLng = position;
    });
    _selectedLatLngNotifier.value = position;
  }

  void _setDestinationLatLng(LatLng? position) {
    if (!mounted) {
      return;
    }
    setState(() {
      _destinationLatLng = position;
    });
    _destinationLatLngNotifier.value = position;
  }

  void _onSelectedLocationDrag(LatLng position) {
    _setSelectedLatLng(position);
  }

  void _onSelectedLocationDragEnd(LatLng position) {
    _setSelectedLatLng(position);
    HapticFeedback.lightImpact();
  }

  Future<void> _waitForSelectionSheetToClose() async {
    var attempts = 0;
    while (_isSelectionSheetOpen && attempts < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      attempts++;
    }
  }

  Future<void> _clearSelectedLocation({bool dismissSheet = true}) async {
    if (dismissSheet && _isSelectionSheetOpen && _selectionSheetContext != null) {
      Navigator.of(_selectionSheetContext!).pop(false);
      await _waitForSelectionSheetToClose();
    }

    if (mounted) {
      setState(() {
        _isSelectingDestination = false;
      });
    } else {
      _isSelectingDestination = false;
    }

    if (_selectedLatLng == null) {
      _selectedLatLngNotifier.value = null;
      _destinationLatLngNotifier.value = null;
      _destinationLatLng = null;
      return;
    }

    _setSelectedLatLng(null);
    _setDestinationLatLng(null);
  }

  Future<void> _showLocationSelectionSheet() async {
    if (!mounted || _selectedLatLng == null || _isSelectionSheetOpen) {
      return;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final paddingValue = 320.0 + bottomInset;

    if (mounted) {
      setState(() {
        _isSelectionSheetOpen = true;
        _mapPadding = EdgeInsets.only(bottom: paddingValue);
      });
    }

    var proceed = false;
    try {
      proceed = await showModalBottomSheet<bool>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (sheetContext) {
              _selectionSheetContext = sheetContext;
              return _StartLocationSheet(
                positionListenable: _selectedLatLngNotifier,
                onConfirm: () => Navigator.of(sheetContext).pop(true),
                onCancel: () => Navigator.of(sheetContext).pop(false),
                reverseGeocode: _reverseGeocode,
              );
            },
          ) ??
          false;
    } finally {
      _selectionSheetContext = null;
      if (mounted) {
        setState(() {
          _mapPadding = EdgeInsets.zero;
          _isSelectionSheetOpen = false;
        });
      } else {
        _mapPadding = EdgeInsets.zero;
        _isSelectionSheetOpen = false;
      }
    }

    if (proceed) {
      await _beginDestinationSelection();
    } else {
      await _clearSelectedLocation(dismissSheet: false);
    }
  }

  Future<void> _beginDestinationSelection() async {
    if (!mounted) {
      return;
    }
    final start = _selectedLatLng;
    if (start == null) {
      await _clearSelectedLocation(dismissSheet: false);
      return;
    }

    if (mounted) {
      setState(() {
        _isSelectingDestination = true;
      });
    } else {
      _isSelectingDestination = true;
    }

    _setDestinationLatLng(null);
    await _moveCamera(start, zoom: 6);
    await _showDestinationSelectionSheet();
  }

  Future<void> _showDestinationSelectionSheet() async {
    if (!mounted || !_isSelectingDestination || _selectedLatLng == null) {
      return;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final paddingValue = 360.0 + bottomInset;

    if (mounted) {
      setState(() {
        _isSelectionSheetOpen = true;
        _mapPadding = EdgeInsets.only(bottom: paddingValue);
      });
    }

    _QuickRoadTripResult? result;
    try {
      result = await showModalBottomSheet<_QuickRoadTripResult>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          _selectionSheetContext = sheetContext;
          return _DestinationSelectionSheet(
            startPositionListenable: _selectedLatLngNotifier,
            destinationListenable: _destinationLatLngNotifier,
            reverseGeocode: _reverseGeocode,
          );
        },
      );
    } finally {
      _selectionSheetContext = null;
      if (mounted) {
        setState(() {
          _mapPadding = EdgeInsets.zero;
          _isSelectionSheetOpen = false;
        });
      } else {
        _mapPadding = EdgeInsets.zero;
        _isSelectionSheetOpen = false;
      }
    }

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
        _activeEventIndex = 0;
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
      _activeEventIndex = selectedIndex;
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

  Future<void> _createEventAt(LatLng latlng) async {
    if (!await _ensureNetworkAvailable()) {
      return;
    }

    if (!await _ensureDisclaimerAccepted()) {
      return;
    }
    if (!mounted) {
      return;
    }
    final data = await showCreateEventBottomSheet(context, latlng);
    if (data == null || data.title.trim().isEmpty) {
      return;
    }

    await ref
        .read(eventsProvider.notifier)
        .createEvent(
          title: data.title.trim(),
          description: data.description.trim(),
          pos: latlng,
          locationName: data.locationName,
        );
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
    if (_showSearchResults) {
      setState(() => _showSearchResults = false);
    }
    ref.read(appOverlayIndexProvider.notifier).state = 0;
  }

  void _onAvatarTap(bool _) {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    if (_showSearchResults) {
      setState(() => _showSearchResults = false);
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
    if (!_searchFocusNode.hasFocus) {
      _searchDebounce?.cancel();
      if (_showSearchResults) {
        setState(() => _showSearchResults = false);
      }
      return;
    }

    final text = _searchController.text.trim();
    if (text.isEmpty) {
      if (_showSearchResults) {
        setState(() => _showSearchResults = false);
      }
      return;
    }

    if (_searchResults.isNotEmpty || _isSearching || _searchError != null) {
      setState(() => _showSearchResults = true);
    } else {
      _triggerSearch(text);
    }
  }

  void _onQueryChanged(String raw) {
    _triggerSearch(raw);
  }

  void _triggerSearch(String raw, {bool immediate = false}) {
    final query = raw.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    setState(() {
      _currentSearchQuery = query;
      _showSearchResults = true;
      _isSearching = true;
      _searchError = null;
    });

    if (immediate) {
      _performSearch(query);
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 350), () {
        _performSearch(query);
      });
    }
  }

  void _onSearchSubmitted(String keyword) {
    _triggerSearch(keyword, immediate: true);
  }

  Future<void> _performSearch(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    try {
      final data = await _api.searchEvents(query);
      if (!mounted || _currentSearchQuery != query) return;
      setState(() {
        _searchResults = data;
      });
    } on ApiException catch (e) {
      if (!mounted || _currentSearchQuery != query) return;
      setState(() {
        _searchResults = const <Event>[];
        _searchError = e.message;
      });
    } finally {
      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchClear() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _clearSearchResults();
  }

  void _onSearchResultTap(Event event) {
    FocusScope.of(context).unfocus();
    setState(() {
      _showSearchResults = false;
      _searchResults = const <Event>[];
      _searchError = null;
      _currentSearchQuery = '';
      _searchController.text = event.title;
    });
    _focusOnEvent(event);
  }

  void _clearSearchResults() {
    setState(() {
      _searchResults = const <Event>[];
      _searchError = null;
      _showSearchResults = false;
      _isSearching = false;
      _currentSearchQuery = '';
    });
  }
}

class _StartLocationSheet extends StatelessWidget {
  const _StartLocationSheet({
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
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
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.map_select_location_title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                loc.map_select_location_tip,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                ),
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
                        key: ValueKey('${position.latitude}_${position.longitude}_start_info'),
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
      ),
    );
  }
}

class _DestinationSelectionSheet extends StatefulWidget {
  const _DestinationSelectionSheet({
    required this.startPositionListenable,
    required this.destinationListenable,
    required this.reverseGeocode,
  });

  final ValueListenable<LatLng?> startPositionListenable;
  final ValueListenable<LatLng?> destinationListenable;
  final Future<String?> Function(LatLng) reverseGeocode;

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
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tipStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.map_select_location_title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.map_select_location_tip,
                  style: tipStyle,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
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
                  valueListenable: widget.startPositionListenable,
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
                          future: widget.reverseGeocode(position),
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
                            final display =
                                (address == null || address.trim().isEmpty)
                                    ? loc.map_location_info_address_unavailable
                                    : address;
                            return _LocationSheetRow(
                              icon: addressIcon,
                              child: Text(display),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<LatLng?>(
                  valueListenable: widget.destinationListenable,
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
                          future: widget.reverseGeocode(position),
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
                            final display =
                                (address == null || address.trim().isEmpty)
                                    ? loc.map_location_info_address_unavailable
                                    : address;
                            return _LocationSheetRow(
                              icon: addressIcon,
                              child: Text(display),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: _isSubmitting ? null : _handleOpenDetailed,
                  icon: const Icon(Icons.auto_awesome_motion_outlined),
                  label: Text(loc.map_select_location_open_detailed),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: Text(loc.action_cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _canCreate ? _handleCreate : null,
                        child: _isSubmitting
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
      ),
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

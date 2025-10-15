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

enum _SelectionSheetState { hidden, collapsed, expanded }

const double _kSheetHiddenExtent = 0.0;
const double _kSheetCollapsedExtent = 0.15;
const double _kSheetExpandedExtent = 0.85;
const double _kSheetSnapVelocityThreshold = 800;
const double _kSheetSnapDistanceThreshold = 0.1;

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
  late final ValueNotifier<LatLng?> _selectedLatLngNotifier;
  bool _isHandlingLongPress = false;
  EdgeInsets _mapPadding = EdgeInsets.zero;
  late final DraggableScrollableController _selectionSheetController;
  _SelectionSheetState _selectionSheetState = _SelectionSheetState.hidden;
  bool _isHidingSelectionSheet = false;

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
    _selectionSheetController = DraggableScrollableController();
    _selectionSheetController.addListener(_handleSelectionSheetExtentChanged);
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
    _selectionSheetController.removeListener(
      _handleSelectionSheetExtentChanged,
    );
    _selectionSheetController.dispose();
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
          onTap: () => unawaited(_showLocationSelectionSheet(expand: true)),
          onDrag: _onSelectedLocationDrag,
          onDragEnd: _onSelectedLocationDragEnd,
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
          _buildLocationSelectionSheetOverlay(),
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

  Widget _buildLocationSelectionSheetOverlay() {
    final hasSelection = _selectedLatLng != null;
    final shouldRenderSheet = hasSelection ||
        _selectionSheetState != _SelectionSheetState.hidden ||
        _isHidingSelectionSheet;

    if (!shouldRenderSheet) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final placesService = ref.read(placesServiceProvider);
    final isCollapsed = _selectionSheetState == _SelectionSheetState.collapsed;
    final isExpanded = _selectionSheetState == _SelectionSheetState.expanded;

    return Stack(
      children: [
        if (isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => unawaited(_collapseSelectionSheet()),
              child: Container(color: Colors.black26),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DraggableScrollableSheet(
            controller: _selectionSheetController,
            expand: false,
            initialChildSize: _kSheetHiddenExtent,
            minChildSize: _kSheetHiddenExtent,
            maxChildSize: _kSheetExpandedExtent,
            snap: true,
            snapSizes: const [
              _kSheetHiddenExtent,
              _kSheetCollapsedExtent,
              _kSheetExpandedExtent,
            ],
            builder: (context, scrollController) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SelectionSheetGrabHandle(
                        onTap: () {
                          if (_selectionSheetState ==
                              _SelectionSheetState.collapsed) {
                            unawaited(_expandSelectionSheet());
                          } else if (_selectionSheetState ==
                              _SelectionSheetState.expanded) {
                            unawaited(_collapseSelectionSheet());
                          }
                        },
                        onVerticalDragUpdate: (details) {
                          final delta = details.primaryDelta;
                          if (delta != null) {
                            _dragSelectionSheetByDelta(delta);
                          }
                        },
                        onVerticalDragEnd: (details) {
                          _snapSelectionSheetByVelocity(
                            details.primaryVelocity ?? 0,
                          );
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _selectionSheetState ==
                                  _SelectionSheetState.collapsed
                              ? () => unawaited(_expandSelectionSheet())
                              : null,
                          child: IgnorePointer(
                            ignoring: isCollapsed,
                            child: _LocationSelectionSheet(
                              positionListenable: _selectedLatLngNotifier,
                              onConfirm: _onSelectionSheetConfirm,
                              onCancel: _onSelectionSheetCancel,
                              reverseGeocode: _reverseGeocode,
                              fetchNearbyPlaces: (position) =>
                                  placesService.searchNearbyPlaces(
                                position,
                                radius: 200,
                                maxResults: 3,
                              ),
                              onPlaceSelected: (place) =>
                                  unawaited(_onNearbyPlaceSelected(place)),
                              scrollController: scrollController,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleSelectionSheetExtentChanged() {
    if (!mounted) {
      return;
    }

    final extent = _selectionSheetController.size;
    _updateMapPaddingForExtent(extent);

    if (_isHidingSelectionSheet) {
      return;
    }

    final nextState = _stateForExtent(extent);
    if (nextState != _selectionSheetState) {
      setState(() => _selectionSheetState = nextState);
    }
  }

  void _updateMapPaddingForExtent(double extent) {
    if (!mounted) {
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final hiddenThreshold = (_kSheetCollapsedExtent + _kSheetHiddenExtent) / 2;
    final targetBottom = extent <= hiddenThreshold
        ? 0.0
        : extent * mediaQuery.size.height +
            mediaQuery.viewPadding.bottom +
            24;

    if ((_mapPadding.bottom - targetBottom).abs() < 2) {
      return;
    }

    setState(() {
      _mapPadding = EdgeInsets.only(bottom: targetBottom);
    });
  }

  _SelectionSheetState _stateForExtent(double extent) {
    if (extent <= (_kSheetCollapsedExtent + _kSheetHiddenExtent) / 2) {
      return _SelectionSheetState.hidden;
    }
    if (extent <= (_kSheetCollapsedExtent + _kSheetExpandedExtent) / 2) {
      return _SelectionSheetState.collapsed;
    }
    return _SelectionSheetState.expanded;
  }

  Future<void> _animateSheetTo(
    double extent, {
    Duration duration = const Duration(milliseconds: 250),
  }) async {
    Future<void> runAnimation() async {
      try {
        await _selectionSheetController.animateTo(
          extent,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      } catch (_) {
        try {
          if ((_selectionSheetController.size - extent).abs() <= 0.001) {
            return;
          }
        } catch (_) {}
        rethrow;
      }
    }

    try {
      await runAnimation();
    } on FlutterError catch (_) {
      _scheduleSheetAnimation(runAnimation);
    } on StateError catch (_) {
      _scheduleSheetAnimation(runAnimation);
    }
  }

  void _scheduleSheetAnimation(Future<void> Function() runAnimation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(runAnimation().catchError((_) {}));
    });
  }

  Future<void> _expandSelectionSheet() async {
    if (!mounted || _selectedLatLng == null) {
      return;
    }
    if (_selectionSheetState != _SelectionSheetState.expanded) {
      setState(() => _selectionSheetState = _SelectionSheetState.expanded);
    }
    _updateMapPaddingForExtent(_kSheetExpandedExtent);
    await _animateSheetTo(
      _kSheetExpandedExtent,
      duration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _collapseSelectionSheet() async {
    if (!mounted) {
      return;
    }
    if (_selectionSheetState == _SelectionSheetState.hidden) {
      return;
    }
    if (_selectionSheetState != _SelectionSheetState.collapsed) {
      setState(() => _selectionSheetState = _SelectionSheetState.collapsed);
    }
    _updateMapPaddingForExtent(_kSheetCollapsedExtent);
    await _animateSheetTo(
      _kSheetCollapsedExtent,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<void> _hideSelectionSheet() async {
    if (!mounted) {
      return;
    }
    double? currentExtent;
    try {
      currentExtent = _selectionSheetController.size;
    } catch (_) {
      currentExtent = null;
    }
    final isAlreadyHidden = _selectionSheetState == _SelectionSheetState.hidden &&
        (currentExtent == null ||
            currentExtent <= _kSheetHiddenExtent + 0.001);
    if (isAlreadyHidden) {
      return;
    }
    _isHidingSelectionSheet = true;
    try {
      await _animateSheetTo(
        _kSheetHiddenExtent,
        duration: const Duration(milliseconds: 200),
      );
    } finally {
      _isHidingSelectionSheet = false;
    }
    if (!mounted) {
      return;
    }
    if (_selectionSheetState != _SelectionSheetState.hidden) {
      setState(() => _selectionSheetState = _SelectionSheetState.hidden);
    }
    _updateMapPaddingForExtent(_kSheetHiddenExtent);
  }

  void _dragSelectionSheetByDelta(double delta) {
    final height = MediaQuery.of(context).size.height;
    if (height <= 0) {
      return;
    }
    double current;
    try {
      current = _selectionSheetController.size;
    } catch (_) {
      return;
    }
    final next = (current - delta / height)
        .clamp(_kSheetHiddenExtent, _kSheetExpandedExtent);
    _selectionSheetController.jumpTo(next);
  }

  void _snapSelectionSheetByVelocity(double velocity) {
    double current;
    try {
      current = _selectionSheetController.size;
    } catch (_) {
      return;
    }
    double target;

    if (velocity.abs() > _kSheetSnapVelocityThreshold) {
      if (velocity > 0) {
        target = current > (_kSheetCollapsedExtent + _kSheetExpandedExtent) / 2
            ? _kSheetCollapsedExtent
            : _kSheetHiddenExtent;
      } else {
        target = _kSheetExpandedExtent;
      }
    } else {
      if (current <= _kSheetCollapsedExtent - _kSheetSnapDistanceThreshold) {
        target = _kSheetHiddenExtent;
      } else if ((current - _kSheetCollapsedExtent).abs() <=
          _kSheetSnapDistanceThreshold) {
        target = _kSheetCollapsedExtent;
      } else {
        target = _kSheetExpandedExtent;
      }
    }

    if (_selectedLatLng == null) {
      target = _kSheetHiddenExtent;
    }

    if (target == _kSheetHiddenExtent) {
      unawaited(_hideSelectionSheet());
    } else if (target == _kSheetCollapsedExtent) {
      unawaited(_showLocationSelectionSheet(expand: false));
    } else {
      unawaited(_expandSelectionSheet());
    }
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
    if (!mounted || _isHandlingLongPress) {
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

  void _onSelectedLocationDrag(LatLng position) {
    _setSelectedLatLng(position);
  }

  void _onSelectedLocationDragEnd(LatLng position) {
    _setSelectedLatLng(position);
    HapticFeedback.lightImpact();
  }

  Future<void> _clearSelectedLocation() async {
    if (_selectedLatLng == null) {
      if (_selectionSheetState != _SelectionSheetState.hidden) {
        await _hideSelectionSheet();
      }
      _selectedLatLngNotifier.value = null;
      return;
    }

    await _hideSelectionSheet();
    _setSelectedLatLng(null);
  }

  Future<void> _showLocationSelectionSheet({bool expand = false}) async {
    if (!mounted || _selectedLatLng == null) {
      return;
    }

    if (expand) {
      await _expandSelectionSheet();
      return;
    }

    if (_selectionSheetState != _SelectionSheetState.collapsed) {
      setState(() => _selectionSheetState = _SelectionSheetState.collapsed);
    }

    _updateMapPaddingForExtent(_kSheetCollapsedExtent);

    await _animateSheetTo(
      _kSheetCollapsedExtent,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<void> _onSelectionSheetConfirm() async {
    final target = _selectedLatLngNotifier.value;
    if (target == null) {
      await _hideSelectionSheet();
      return;
    }

    await _hideSelectionSheet();
    if (!mounted) {
      return;
    }

    await _createEventAt(target);
    if (!mounted) {
      return;
    }
    _setSelectedLatLng(null);
  }

  Future<void> _onSelectionSheetCancel() async {
    await _clearSelectedLocation();
  }

  Future<void> _onNearbyPlaceSelected(NearbyPlace place) async {
    final location = place.location;
    if (location == null) {
      return;
    }
    _setSelectedLatLng(location);
    await _moveCamera(location, zoom: 17);
    await HapticFeedback.selectionClick();
    await _expandSelectionSheet();
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

    if (_selectionSheetState == _SelectionSheetState.expanded) {
      await _collapseSelectionSheet();
      return;
    }

    if (_selectionSheetState == _SelectionSheetState.collapsed) {
      await _clearSelectedLocation();
      return;
    }

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

  void _onAvatarTap(bool authed) {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    if (_showSearchResults) {
      setState(() => _showSearchResults = false);
    }
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

class _SelectionSheetGrabHandle extends StatelessWidget {
  const _SelectionSheetGrabHandle({
    this.onTap,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final VoidCallback? onTap;
  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;
  final ValueChanged<DragEndDetails> onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationSelectionSheet extends StatelessWidget {
  const _LocationSelectionSheet({
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
    required this.onPlaceSelected,
    required this.scrollController,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ValueChanged<NearbyPlace> onPlaceSelected;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: ListView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
        children: [
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
                      const Icon(Icons.place_outlined, color: Colors.redAccent),
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
                    key: ValueKey('${position.latitude}_${position.longitude}'),
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
                  const SizedBox(height: 20),
                  _NearbyPlacesList(
                    selectedPosition: position,
                    fetchNearbyPlaces: fetchNearbyPlaces,
                    onPlaceSelected: onPlaceSelected,
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

class _NearbyPlacesList extends StatelessWidget {
  const _NearbyPlacesList({
    required this.selectedPosition,
    required this.fetchNearbyPlaces,
    required this.onPlaceSelected,
  });

  final LatLng selectedPosition;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ValueChanged<NearbyPlace> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.map_location_info_nearby_title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<NearbyPlace>>(
          key: ValueKey(
            'nearby_${selectedPosition.latitude}_${selectedPosition.longitude}',
          ),
          future: fetchNearbyPlaces(selectedPosition),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error;
              String message = loc.map_location_info_nearby_error;
              if (error is PlacesApiException) {
                if (error.message.contains('not configured')) {
                  message = loc.map_place_details_missing_api_key;
                } else if (error.message.trim().isNotEmpty) {
                  message = error.message;
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            final places = (snapshot.data ?? const <NearbyPlace>[])
                .where((place) => place.location != null)
                .take(3)
                .toList(growable: false);
            if (places.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  loc.map_location_info_nearby_empty,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final place = places[index];
                return _NearbyPlaceTile(
                  place: place,
                  selected: _isSameLocation(
                    place.location!,
                    selectedPosition,
                  ),
                  onTap: () => onPlaceSelected(place),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: places.length,
            );
          },
        ),
      ],
    );
  }

  bool _isSameLocation(LatLng a, LatLng b) {
    const tolerance = 1e-5;
    return (a.latitude - b.latitude).abs() < tolerance &&
        (a.longitude - b.longitude).abs() < tolerance;
  }
}

class _NearbyPlaceTile extends StatelessWidget {
  const _NearbyPlaceTile({
    required this.place,
    required this.onTap,
    required this.selected,
  });

  final NearbyPlace place;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAddress = place.formattedAddress != null &&
        place.formattedAddress!.trim().isNotEmpty;

    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.primary.withOpacity(0.12);
    final defaultIconColor = theme.colorScheme.onSurfaceVariant;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      color: selected ? selectedColor : null,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.place_outlined,
          color: selected ? colorScheme.primary : defaultIconColor,
        ),
        title: Text(
          place.displayName,
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: hasAddress
            ? Text(
                place.formattedAddress!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/presentation/widgets/disclaimer_sheet.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/state/disclaimer_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/app_floating_action_button.dart';

import '../../data/event.dart';
import '../../data/event_filter.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/state/di/providers.dart';
import '../../../../core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/map_event_floating_card.dart';
import 'sheets/map_event_filter_sheet.dart';
import 'sheets/map_create_event_sheet.dart';
import 'sheets/map_place_details_sheet.dart';
import 'sheets/map_location_info_sheet.dart';
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
  final _allCategories = const ['派对', '运动', '音乐', '户外', '学习', '展览', '美食'];
  static const _quickTags = [
    'today',
    'nearby',
    'party',
    'sports',
    'music',
    'free',
    'trending',
    'friends',
  ];
  final _selectedTags = <String>{};

  // 搜索框
  final _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  late final ApiService _api;
  EventFilter _filter = const EventFilter();
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
    final loc = AppLocalizations.of(context)!;
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
      data: (list) =>
          MarkersLayer.fromEvents(events: list, onEventTap: _focusOnEvent),
    );

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
        tags: _quickTags,
        selected: _selectedTags,
        onTagToggle: (t, v) => setState(() {
          v ? _selectedTags.add(t) : _selectedTags.remove(t);
          // TODO: 将标签映射到 _filter 并刷新 Provider
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
        }),
        onOpenFilter: () async {
          final res = await showEventFilterSheet(
            context: context,
            initial: _filter,
            allCategories: _allCategories,
          );
          if (res != null) setState(() => _filter = res);
          // TODO: 根据 _filter 刷新数据
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
        },
        onResultTap: _onSearchResultTap,
        showResults: _showSearchResults,
        isLoading: _isSearching,
        results: _searchResults,
        errorText: _searchError,
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
              markers: markersLayer.markers,
              showUserLocation: true,
              showMyLocationButton: true,
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
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
              },
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
    _hideEventCard();

    final addressFuture = _reverseGeocode(latlng);
    final placesService = ref.read(placesServiceProvider);
    Future<List<NearbyPlace>>? nearbyPlacesFuture;
    try {
      nearbyPlacesFuture = placesService.searchNearbyPlaces(
        latlng,
        radius: 100,
        maxResults: 8,
      );
    } on PlacesApiException catch (error) {
      nearbyPlacesFuture = Future<List<NearbyPlace>>.error(error);
    } catch (error) {
      nearbyPlacesFuture = Future<List<NearbyPlace>>.error(error);
    }

    await showMapLocationInfoSheet(
      context: context,
      position: latlng,
      addressFuture: addressFuture,
      nearbyPlacesFuture: nearbyPlacesFuture,
      onCreateEvent: () async {
        Navigator.of(context).pop();
        await _createEventAt(latlng);
      },
    );
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
    List<Event> updatedList;
    int targetIndex;
    if (list.isEmpty) {
      updatedList = <Event>[ev];
      targetIndex = 0;
    } else {
      final index = list.indexWhere((event) => event.id == ev.id);
      if (index == -1) {
        updatedList = <Event>[ev, ...list];
        targetIndex = 0;
      } else {
        updatedList = list;
        targetIndex = index;
      }
    }

    setState(() {
      _carouselEvents = updatedList;
      _isEventCardVisible = true;
      _activeEventIndex = targetIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_eventCardController.hasClients) {
        return;
      }
      _eventCardController.jumpToPage(targetIndex);
    });
    _updateBottomNavigation(false);
  }

  void _focusOnEvent(Event event) {
    if (!mounted) {
      return;
    }
    _moveCamera(LatLng(event.latitude, event.longitude), zoom: 14);
    _movedToSelected = true;
    _showEventCard(event);
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

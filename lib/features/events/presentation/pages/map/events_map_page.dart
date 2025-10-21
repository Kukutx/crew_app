import 'dart:async';

import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/presentation/pages/map/services/map_interaction_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/services/map_selection_flow.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/events_map_ui_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_quick_actions_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/events_map_fab_column.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/quick_actions_drawer.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import '../../../data/event.dart';
import '../detail/events_detail_page.dart';
import 'state/events_map_search_controller.dart';
import 'widgets/events_map_event_carousel.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/search_event_appbar.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _map;
  bool _mapReady = false;
  late final PageController _eventCardController;
  final _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  ProviderSubscription<Event?>? _mapFocusSubscription;
  ProviderSubscription<MapQuickAction?>? _quickActionSubscription;
  ProviderSubscription<EventsMapUiState>? _uiStateSubscription;
  ProviderSubscription<AsyncValue<LatLng?>>? _locationSubscription;

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
      _onEventTapped(event);
      ref.read(mapFocusEventProvider.notifier).state = null;
    });
    _quickActionSubscription = ref.listenManual(
      mapQuickActionProvider,
      (previous, next) {
        final action = next;
        if (action == null) {
          return;
        }
        switch (action) {
          case MapQuickAction.startQuickTrip:
            unawaited(
              ref
                  .read(mapInteractionControllerProvider)
                  .startQuickTripFromQuickActions(
                    context,
                    _moveCamera,
                    _hideEventCard,
                  ),
            );
            break;
          case MapQuickAction.showMomentSheet:
            if (mounted) {
              unawaited(showCreateMomentSheet(context));
            }
            break;
        }
        ref.read(mapQuickActionProvider.notifier).state = null;
      },
    );
    _uiStateSubscription = ref.listenManual(
      eventsMapUiControllerProvider,
      (previous, next) {
        final isDrawerOpen = _scaffoldKey.currentState?.isDrawerOpen ?? false;
        _updateBottomNavigation(!next.isEventCardVisible && !isDrawerOpen);
        final shouldJump =
            next.isEventCardVisible && next.carouselEvents.isNotEmpty;
        if (shouldJump &&
            _eventCardController.hasClients &&
            (previous?.initialPage != next.initialPage ||
                !(previous?.isEventCardVisible ?? false))) {
          _eventCardController.jumpToPage(next.initialPage);
        }
      },
    );
    _locationSubscription = ref.listenManual(
      userLocationProvider,
      (previous, next) {
        final location = next.value;
        final uiState = ref.read(eventsMapUiControllerProvider);
        if (!(uiState.hasMovedToSelected) &&
            widget.selectedEvent == null &&
            location != null) {
          unawaited(_moveCamera(location, zoom: 14));
          ref
              .read(eventsMapUiControllerProvider.notifier)
              .setHasMovedToSelected(true);
        }
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
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapFocusSubscription?.close();
    _quickActionSubscription?.close();
    _uiStateSubscription?.close();
    _locationSubscription?.close();
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
    final uiState = ref.watch(eventsMapUiControllerProvider);
    final cardVisible =
        uiState.isEventCardVisible && uiState.carouselEvents.isNotEmpty;
    final bottomPadding = (cardVisible ? 240 : 120) + safeBottom;
    final searchState = ref.watch(eventsMapSearchControllerProvider);
    final loc = AppLocalizations.of(context)!;

    final events = ref.watch(eventsProvider);
    final userLoc = ref.watch(userLocationProvider).value;
    final startCenter = userLoc ?? const LatLng(48.8566, 2.3522);
    final selectionState = ref.watch(mapSelectionControllerProvider);

    final markersLayer = events.when(
      loading: () => const MarkersLayer(markers: <Marker>{}),
      error: (_, _) => const MarkersLayer(markers: <Marker>{}),
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: _onEventTapped,
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
          onTap: () => unawaited(_showStartSelectionSheet()),
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
          onTap: () => unawaited(_showStartSelectionSheet()),
        ),
      );
    }

    // 页面首帧跳转至选中事件,如果有选中事件，页面初始化时直接跳过去
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasMoved =
          ref.read(eventsMapUiControllerProvider).hasMovedToSelected;
      if (widget.selectedEvent != null && !hasMoved) {
        _onEventTapped(widget.selectedEvent!);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true, // 关键：让地图顶到状态栏
      key: _scaffoldKey,
      drawer: MapQuickActionsDrawer(
        onClose: () => Navigator.of(context).pop(),
      ),
      onDrawerChanged: (isOpened) {
        _updateBottomNavigation(!isOpened && !uiState.isEventCardVisible);
      },
      appBar: SearchEventAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onSearch: _onSearchSubmitted,
        onChanged: _onQueryChanged,
        onClear: _onSearchClear,
        onQuickActionsTap: _openQuickActionsDrawer,
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
          events: uiState.carouselEvents,
          visible: uiState.isEventCardVisible &&
              uiState.carouselEvents.isNotEmpty,
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
      floatingActionButton: EventsMapFabColumn(
        bottomPadding: bottomPadding,
        onCreateMoment: () => showCreateMomentSheet(context),
        onMyLocation: () async {
          final loc = ref.read(userLocationProvider).value;
          if (loc != null) {
            await _moveCamera(loc, zoom: 14);
          } else {
            _showSnackBar('Unable to get location');
          }
        },
      ),
    );
  }

  void _onEventCardPageChanged(int index) {
    final events = ref.read(eventsMapUiControllerProvider).carouselEvents;
    if (index < 0 || index >= events.length) {
      return;
    }
    final event = events[index];
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
      _onEventTapped(result);
    }
  }

  void _onEventTapped(Event event) {
    ref.read(mapInteractionControllerProvider).focusOnEvent(
          event,
          _moveCamera,
          _eventCardController,
          ref,
        );
  }

  void _hideEventCard() {
    final state = ref.read(eventsMapUiControllerProvider);
    if (!state.isEventCardVisible) {
      return;
    }
    ref.read(eventsMapUiControllerProvider.notifier).hideEventCard();
    _updateBottomNavigation(true);
  }

  void _openQuickActionsDrawer() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    final searchController =
        ref.read(eventsMapSearchControllerProvider.notifier);
    searchController.hideResults();
    _scaffoldKey.currentState?.openDrawer();
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
    final hasMoved = ref.read(eventsMapUiControllerProvider).hasMovedToSelected;
    if (!hasMoved && loc != null) {
      unawaited(_moveCamera(loc, zoom: 14));
      ref
          .read(eventsMapUiControllerProvider.notifier)
          .setHasMovedToSelected(true);
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

  Future<void> _onMapTap(LatLng position) async {
    final flow = ref.read(mapSelectionFlowProvider);
    final selectionState = ref.read(mapSelectionControllerProvider);

    if (selectionState.isSelectionSheetOpen) {
      return;
    }

    if (selectionState.isSelectingDestination) {
      final result = await flow.handleDestinationSelection(
        context,
        position,
        _moveCamera,
      );
      if (!mounted) {
        return;
      }
      if (result != null) {
        await ref
            .read(mapInteractionControllerProvider)
            .handleQuickTripResult(context, result);
      }
      return;
    }

    if (!mounted) {
      return;
    }

    _hideEventCard();
    await ref.read(mapInteractionControllerProvider).onMapTap(
          context,
          position,
        );
  }

  Future<void> _onMapLongPress(LatLng latlng) async {
    if (!mounted) {
      return;
    }
    final result = await ref
        .read(mapSelectionFlowProvider)
        .handleLongPress(context, latlng, _moveCamera, _hideEventCard);
    if (result != null) {
      await ref
          .read(mapInteractionControllerProvider)
          .handleQuickTripResult(context, result);
    }
  }

  void _onSelectedLocationDrag(LatLng position) {
    ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(position);
  }

  void _onSelectedLocationDragEnd(LatLng position) {
    _onSelectedLocationDrag(position);
  }

  Future<void> _clearSelectedLocation({bool dismissSheet = true}) {
    return ref
        .read(mapSelectionFlowProvider)
        .clearSelectedLocation(dismissSheet: dismissSheet);
  }

  Future<void> _showStartSelectionSheet() {
    return ref
        .read(mapSelectionFlowProvider)
        .showStartLocationSheet(context, _moveCamera);
  }

  void _onAvatarTap(bool authed) {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
    ref.read(mapInteractionControllerProvider).onAvatarTap(context, authed);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
    _onEventTapped(event);
  }
}

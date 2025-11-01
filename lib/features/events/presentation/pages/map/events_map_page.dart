import 'dart:async';

import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_explore_sheet.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:crew_app/shared/widgets/app_drawer.dart';

import '../../../data/event.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/events_map_event_carousel.dart';
import 'state/events_map_search_controller.dart';
import 'state/map_selection_controller.dart';
import 'controllers/map_controller.dart';
import 'controllers/event_carousel_manager.dart';
import 'controllers/search_manager.dart';
import 'controllers/location_selection_manager.dart';
import 'state/map_overlay_sheet_provider.dart';

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

  @override
  void initState() {
    super.initState();
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
    _carouselSubscription = ref.listenManual(eventCarouselManagerProvider, (
      _,
      manager,
    ) {
      if (!mounted) {
        return;
      }
      _updateBottomNavigation(!_isDrawerOpen && !manager.isVisible);
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
    final locationSelectionManager = ref.watch(
      locationSelectionManagerProvider,
    );
    final mapSheetType = ref.watch(mapOverlaySheetProvider);

    final cardVisible =
        carouselManager.isVisible && carouselManager.events.isNotEmpty;
    final bottomPadding = (cardVisible ? 240 : 120) + safeBottom;
    final searchState = ref.watch(eventsMapSearchControllerProvider);
    final loc = AppLocalizations.of(context)!;

    final events = ref.watch(eventsProvider);
    final startCenter = mapController.getInitialCenter();
    final selectionState = ref.watch(mapSelectionControllerProvider);

    final markersLayer = events.when(
      loading: () => const MarkersLayer(markers: <Marker>{}),
      error: (_, _) => const MarkersLayer(markers: <Marker>{}),
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: (event) {
          mapController.focusOnEvent(event);
          carouselManager.showEventCard(event);
        },
      ),
    );

    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null ||
        selectionState.isSelectingDestination;
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
          onTap: () =>
              unawaited(locationSelectionManager.clearSelectedLocation()),
          onDrag: (pos) => ref
              .read(mapSelectionControllerProvider.notifier)
              .setSelectedLatLng(pos),
          onDragEnd: (pos) {
            ref
                .read(mapSelectionControllerProvider.notifier)
                .setSelectedLatLng(pos);
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
          onTap: () =>
              unawaited(locationSelectionManager.clearSelectedLocation()),
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

    final hideSearchBar =
        selectionState.isSelectionSheetOpen ||
        selectionState.isSelectingDestination ||
        selectionState.selectedLatLng != null;
    final showClearSelectionInAppBar =
        !hideSearchBar && selectionState.selectedLatLng != null;

    if (hideSearchBar &&
        (searchManager.searchFocusNode.hasFocus || searchState.showResults)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final manager = ref.read(searchManagerProvider);
        if (manager.searchFocusNode.hasFocus) {
          manager.searchFocusNode.unfocus();
        }
        ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      drawer: AppDrawer(onClose: () => Navigator.of(context).pop()),
      onDrawerChanged: (isOpened) {
        _isDrawerOpen = isOpened;
        _updateBottomNavigation(!isOpened && !carouselManager.isVisible);
      },
      appBar: hideSearchBar
          ? null
          : SearchEventAppBar(
              controller: searchManager.searchController,
              focusNode: searchManager.searchFocusNode,
              onSearch: searchManager.onSearchSubmitted,
              onChanged: searchManager.onQueryChanged,
              onClear: searchManager.clearSearch,
              onQuickActionsTap: _openQuickActionsDrawer,
              onAvatarTap: _onAvatarTap,
              onResultTap: (event) =>
                  searchManager.onSearchResultTap(event, context),
              showResults: searchState.showResults,
              isLoading: searchState.isLoading,
              results: searchState.results,
              errorText: searchState.errorText,
              showClearSelectionAction: showClearSelectionInAppBar,
              onClearSelection: showClearSelectionInAppBar
                  ? () => unawaited(
                      locationSelectionManager.clearSelectedLocation(),
                    )
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
                unawaited(
                  locationSelectionManager.onMapLongPress(pos, context),
                );
              },
              markers: markers,
              showUserLocation: true,
              mapPadding: selectionState.mapPadding,
            ),
          ),
          EventsMapEventCarousel(
            events: carouselManager.events,
            visible:
                carouselManager.isVisible && carouselManager.events.isNotEmpty,
            controller: carouselManager.pageController,
            safeBottom: safeBottom,
            onPageChanged: carouselManager.onPageChanged,
            onOpenDetails: (event) =>
                carouselManager.openEventDetails(event, context),
            onClose: carouselManager.hideEventCard,
            onRegister: () => _showSnackBar(loc.registration_not_implemented),
            onFavorite: () => _showSnackBar(loc.feature_not_ready),
          ),
          if (hideSearchBar)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectionState.isSelectingDestination
                                  ? loc.map_select_location_destination_tip
                                  : loc.map_select_location_tip,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: .8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () => unawaited(
                              locationSelectionManager.clearSelectedLocation(),
                            ),
                            icon: const Icon(Icons.close),
                            label: Text(loc.map_clear_selected_point),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (mapSheetType != MapOverlaySheetType.none)
            _MapOverlaySheet(sheetType: mapSheetType),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: AppFloatingActionButton(
              heroTag: 'events_map_add_fab',
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
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

  void _openQuickActionsDrawer() {
    final searchManager = ref.read(searchManagerProvider);
    if (searchManager.searchFocusNode.hasFocus) {
      searchManager.searchFocusNode.unfocus();
    }
    final searchController = ref.read(
      eventsMapSearchControllerProvider.notifier,
    );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    ref.read(appOverlayIndexProvider.notifier).state = 1;
  }
}

class _MapOverlaySheet extends ConsumerWidget {
  const _MapOverlaySheet({required this.sheetType});

  static const double _minChildSize = 0.25;
  static const double _maxChildSize = 0.92;

  final MapOverlaySheetType sheetType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final handleColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.18);

    final initialSize = sheetType == MapOverlaySheetType.chat ? 0.42 : 0.36;

    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          expand: false,
          minChildSize: _minChildSize,
          maxChildSize: _maxChildSize,
          initialChildSize: initialSize,
          builder: (context, scrollController) {
            final Widget effectiveContent;
            switch (sheetType) {
              case MapOverlaySheetType.explore:
                effectiveContent = MapExploreSheet(scrollController: scrollController);
                break;
              case MapOverlaySheetType.chat:
                effectiveContent = ChatSheet(scrollController: scrollController);
                break;
              case MapOverlaySheetType.none:
                effectiveContent = const SizedBox.shrink();
                break;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.14),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 46,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: handleColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close),
                              onPressed: () => ref
                                  .read(mapOverlaySheetProvider.notifier)
                                  .state = MapOverlaySheetType.none,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SafeArea(
                          top: false,
                          child: effectiveContent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

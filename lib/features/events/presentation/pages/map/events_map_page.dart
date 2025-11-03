import 'dart:async';

import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_explore_sheet.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:crew_app/app/view/app_drawer.dart';

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
import 'state/map_overlay_sheet_stage_provider.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProviderSubscription<Event?>? _mapFocusSubscription;
  bool _isDrawerOpen = false;
  final ClusterManagerId _eventsClusterManagerId =
      const ClusterManagerId('events_cluster_manager');
  late final ClusterManager _eventsClusterManager;
  late final MapController _mapController;
  late final EventCarouselManager _carouselManager;
  late final SearchManager _searchManager;
  late final LocationSelectionManager _locationSelectionManager;
  bool _isCarouselVisible = false;

  @override
  void initState() {
    super.initState();
    _mapController = ref.read(mapControllerProvider);
    _carouselManager = ref.read(eventCarouselManagerProvider);
    _searchManager = ref.read(searchManagerProvider);
    _locationSelectionManager = ref.read(locationSelectionManagerProvider);
    _isCarouselVisible =
        _carouselManager.isVisible && _carouselManager.events.isNotEmpty;
    _eventsClusterManager = ClusterManager(
      clusterManagerId: _eventsClusterManagerId,
      onClusterTap: (cluster) {
        unawaited(_mapController.moveCamera(cluster.position, zoom: 14));
      },
    );
    _mapFocusSubscription = ref.listenManual(mapFocusEventProvider, (
      previous,
      next,
    ) {
      final event = next;
      if (event == null) {
        return;
      }
      _mapController.focusOnEvent(event);
      _carouselManager.showEventCard(event);
      ref.read(mapFocusEventProvider.notifier).state = null;
    });
    ref.listen<bool>(
      eventCarouselManagerProvider.select(
        (manager) => manager.isVisible && manager.events.isNotEmpty,
      ),
      (_, isVisible) {
        if (!mounted) {
          return;
        }
        if (_isCarouselVisible != isVisible) {
          setState(() => _isCarouselVisible = isVisible);
        }
        _updateBottomNavigation(!_isDrawerOpen && !isVisible);
      },
    );
    ref.listen<MapOverlaySheetType>(
      mapOverlaySheetProvider,
      (previous, next) {
        if (next != MapOverlaySheetType.none || !mounted) {
          return;
        }
        final notifier = ref.read(mapOverlaySheetStageProvider.notifier);
        if (notifier.state != MapOverlaySheetStage.collapsed) {
          notifier.state = MapOverlaySheetStage.collapsed;
        }
      },
    );
    ref.listen<MapSelectionState>(
      mapSelectionControllerProvider,
      (previous, next) {
        final shouldHide = _shouldHideSearchBar(next);
        final wasHidden = previous != null && _shouldHideSearchBar(previous);
        if (!shouldHide || wasHidden) {
          return;
        }
        if (_searchManager.searchFocusNode.hasFocus) {
          _searchManager.searchFocusNode.unfocus();
        }
        final searchState = ref.read(eventsMapSearchControllerProvider);
        if (searchState.showResults) {
          ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateBottomNavigation(true);
      if (widget.selectedEvent != null && !_mapController.movedToSelected) {
        _mapController.focusOnEvent(widget.selectedEvent!);
        _carouselManager.showEventCard(widget.selectedEvent!);
      }
    });
  }

  @override
  void dispose() {
    _mapFocusSubscription?.close();
    final controller = ref.read(bottomNavigationVisibilityProvider.notifier);
    if (controller.state) {
      controller.state = false;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventsMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEvent == null ||
        widget.selectedEvent == oldWidget.selectedEvent) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _mapController.focusOnEvent(widget.selectedEvent!);
      _carouselManager.showEventCard(widget.selectedEvent!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    final mapController = _mapController;
    final carouselManager = _carouselManager;
    final searchManager = _searchManager;
    final locationSelectionManager = _locationSelectionManager;
    final mapSheetType = ref.watch(mapOverlaySheetProvider);
    final isSheetExpanded = ref.watch(
      mapOverlaySheetStageProvider
          .select((stage) => stage == MapOverlaySheetStage.expanded),
    );
    final showBottomNavigation = ref.watch(bottomNavigationVisibilityProvider);

    final bottomPadding = (_isCarouselVisible ? 240 : 120) + safeBottom;
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
        clusterManagerId: _eventsClusterManagerId,
      ),
    );

    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null ||
        selectionState.isSelectingDestination;
    final markers = <Marker>{
      if (!shouldHideEventMarkers) ...markersLayer.markers,
    };
    final clusterManagers = <ClusterManager>{
      if (!shouldHideEventMarkers) _eventsClusterManager,
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

    final hideSearchBar =
        selectionState.isSelectionSheetOpen ||
        selectionState.isSelectingDestination ||
        selectionState.selectedLatLng != null;
    final showClearSelectionInAppBar =
        !hideSearchBar && selectionState.selectedLatLng != null;

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
          : _SlidingAppBar(
              hidden: !showBottomNavigation ||
                  (mapSheetType != MapOverlaySheetType.none && isSheetExpanded),
              child: _SearchAppBar(
                searchManager: searchManager,
                onQuickActionsTap: _openQuickActionsDrawer,
                onAvatarTap: _onAvatarTap,
                showClearSelectionAction: showClearSelectionInAppBar,
                onClearSelection: showClearSelectionInAppBar
                    ? () => unawaited(
                          locationSelectionManager.clearSelectedLocation(),
                        )
                    : null,
              ),
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
              clusterManagers: clusterManagers,
              showUserLocation: true,
              mapPadding: selectionState.mapPadding,
            ),
          ),
          _EventCarousel(
            manager: carouselManager,
            safeBottom: safeBottom,
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
    if (_searchManager.searchFocusNode.hasFocus) {
      _searchManager.searchFocusNode.unfocus();
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
    if (_searchManager.searchFocusNode.hasFocus) {
      _searchManager.searchFocusNode.unfocus();
    }
    ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
    if (!authed) {
      if (!mounted) {
        return;
      }
      context.push(AppRoutePaths.login);
      return;
    }
    ref.read(appOverlayIndexProvider.notifier).state = 1;
  }

  bool _shouldHideSearchBar(MapSelectionState state) {
    return state.isSelectionSheetOpen ||
        state.isSelectingDestination ||
        state.selectedLatLng != null;
  }
}

class _MapOverlaySheet extends ConsumerStatefulWidget {
  const _MapOverlaySheet({required this.sheetType});

  final MapOverlaySheetType sheetType;

  @override
  ConsumerState<_MapOverlaySheet> createState() => _MapOverlaySheetState();
}

class _SlidingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SlidingAppBar({required this.child, required this.hidden});

  final PreferredSizeWidget child;
  final bool hidden;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      offset: Offset(0, hidden ? -1.2 : 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        opacity: hidden ? 0 : 1,
        child: child,
      ),
    );
  }
}

class _MapOverlaySheetState extends ConsumerState<_MapOverlaySheet> {
  late final DraggableScrollableController _controller;
  double _currentSize = 0;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController()
      ..addListener(_handleSizeChanged);
    _currentSize = _initialSize;
    _notifyStage(_currentSize);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSizeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleSizeChanged() {
    final size = _controller.size;
    if ((size - _currentSize).abs() < 1e-4 || !mounted) {
      return;
    }

    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.idle) {
      _notifyStage(size);
      setState(() => _currentSize = size);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _notifyStage(size);
      setState(() => _currentSize = size);
    });
  }

  void _onDragUpdate(
    DragUpdateDetails details,
    double minSize,
    double maxSize,
    double height,
  ) {
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) {
      return;
    }
    final proposed = (_controller.size - delta / height).clamp(minSize, maxSize);
    if (proposed != _controller.size) {
      _controller.jumpTo(proposed);
    }
  }

  void _onDragEnd(
    DragEndDetails details,
    List<double> snapSizes,
  ) {
    final velocity = details.primaryVelocity ?? 0;
    final currentSize = _currentSize;
    final target = _targetSnapFor(currentSize, velocity, snapSizes);
    if ((target - currentSize).abs() < 0.001) {
      return;
    }
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  double _targetSnapFor(double size, double velocity, List<double> snapSizes) {
    if (velocity.abs() < 50) {
      return _nearestSnap(size, snapSizes);
    }
    if (velocity < 0) {
      for (final snap in snapSizes) {
        if (snap > size + 1e-4) {
          return snap;
        }
      }
      return snapSizes.last;
    }
    for (final snap in snapSizes.reversed) {
      if (snap < size - 1e-4) {
        return snap;
      }
    }
    return snapSizes.first;
  }

  double _nearestSnap(double size, List<double> snapSizes) {
    double closest = snapSizes.first;
    double distance = (size - closest).abs();
    for (final snap in snapSizes.skip(1)) {
      final d = (size - snap).abs();
      if (d < distance) {
        closest = snap;
        distance = d;
      }
    }
    return closest;
  }

  List<double> get _snapSizes {
    return switch (widget.sheetType) {
      MapOverlaySheetType.chat => const [0.32, 0.5, 0.92],
      MapOverlaySheetType.explore => const [0.32, 0.5, 0.92],
      MapOverlaySheetType.none => const [0.2, 0.5, 0.92],
    };
  }

  double get _initialSize {
    final snapSizes = _snapSizes;
    return switch (widget.sheetType) {
      MapOverlaySheetType.chat => snapSizes[1],
      MapOverlaySheetType.explore => snapSizes[1],
      MapOverlaySheetType.none => snapSizes.first,
    };
  }

  @override
  void didUpdateWidget(covariant _MapOverlaySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheetType != widget.sheetType) {
      final newSize = _initialSize;
      setState(() => _currentSize = newSize);
      _notifyStage(newSize);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        DraggableScrollableActuator.reset(context);
      });
    }
  }

  void _notifyStage(double size) {
    final notifier = ref.read(mapOverlaySheetStageProvider.notifier);
    final newStage = _stageForSize(size);
    if (notifier.state == newStage) {
      return;
    }

    void updateStage() {
      if (!mounted) {
        return;
      }
      notifier.state = newStage;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks) {
      updateStage();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => updateStage());
  }

  MapOverlaySheetStage _stageForSize(double size) {
    final snapSizes = _snapSizes;
    if (snapSizes.isEmpty) {
      return MapOverlaySheetStage.collapsed;
    }
    if (size >= snapSizes.last - 0.01) {
      return MapOverlaySheetStage.expanded;
    }
    if (snapSizes.length > 1 && size >= snapSizes[1] - 0.01) {
      return MapOverlaySheetStage.middle;
    }
    return MapOverlaySheetStage.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final handleColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.2);

    final snapSizes = _snapSizes;
    final initialSize = _initialSize;

    final mediaQuery = MediaQuery.of(context);
    final totalHeight = mediaQuery.size.height;
    final currentSize = _currentSize;
    final isExpanded = currentSize >= snapSizes.last - 0.01;
    final actionIcon = isExpanded
        ? Icons.keyboard_arrow_down_rounded
        : Icons.close;

    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          controller: _controller,
          expand: false,
          minChildSize: snapSizes.first,
          maxChildSize: snapSizes.last,
          initialChildSize: initialSize,
          snap: true,
          snapSizes: snapSizes,
          builder: (context, scrollController) {
            final Widget effectiveContent;
            switch (widget.sheetType) {
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
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Material(
                color: colorScheme.surface,
                elevation: 12,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) => _onDragUpdate(
                        details,
                        snapSizes.first,
                        snapSizes.last,
                        totalHeight,
                      ),
                      onVerticalDragEnd: (details) =>
                          _onDragEnd(details, snapSizes),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: handleColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(actionIcon),
                                onPressed: () {
                                  if (isExpanded) {
                                    _controller.animateTo(
                                      snapSizes[snapSizes.length - 2],
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOutCubic,
                                    );
                                    return;
                                  }
                                  ref
                                      .read(mapOverlaySheetProvider.notifier)
                                      .state = MapOverlaySheetType.none;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: effectiveContent),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchAppBar extends ConsumerWidget {
  const _SearchAppBar({
    required this.searchManager,
    required this.onQuickActionsTap,
    required this.onAvatarTap,
    required this.showClearSelectionAction,
    required this.onClearSelection,
  });

  final SearchManager searchManager;
  final VoidCallback onQuickActionsTap;
  final void Function(bool authed) onAvatarTap;
  final bool showClearSelectionAction;
  final VoidCallback? onClearSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(eventsMapSearchControllerProvider);

    return SearchEventAppBar(
      controller: searchManager.searchController,
      focusNode: searchManager.searchFocusNode,
      onSearch: searchManager.onSearchSubmitted,
      onChanged: searchManager.onQueryChanged,
      onClear: searchManager.clearSearch,
      onQuickActionsTap: onQuickActionsTap,
      onAvatarTap: onAvatarTap,
      onResultTap: (event) => searchManager.onSearchResultTap(event, context),
      showResults: searchState.showResults,
      isLoading: searchState.isLoading,
      results: searchState.results,
      errorText: searchState.errorText,
      showClearSelectionAction: showClearSelectionAction,
      onClearSelection: onClearSelection,
    );
  }
}

class _EventCarousel extends ConsumerWidget {
  const _EventCarousel({
    required this.manager,
    required this.safeBottom,
    required this.onRegister,
    required this.onFavorite,
  });

  final EventCarouselManager manager;
  final double safeBottom;
  final VoidCallback onRegister;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(
      eventCarouselManagerProvider.select((manager) => manager.events),
    );
    final visible = ref.watch(
      eventCarouselManagerProvider.select(
        (manager) => manager.isVisible && manager.events.isNotEmpty,
      ),
    );

    if (events.isEmpty && !visible) {
      return const SizedBox.shrink();
    }

    return EventsMapEventCarousel(
      events: events,
      visible: visible,
      controller: manager.pageController,
      safeBottom: safeBottom,
      onPageChanged: manager.onPageChanged,
      onOpenDetails: (event) => manager.openEventDetails(event, context),
      onClose: manager.hideEventCard,
      onRegister: onRegister,
      onFavorite: onFavorite,
    );
  }
}

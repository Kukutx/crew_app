import 'package:crew_app/features/events/presentation/pages/map/sheets/collapsible_sheet_route.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/destination_selection_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/start_location_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

class MapSelectionFlow {
  MapSelectionFlow(this._ref);

  final WidgetRef _ref;
  BuildContext? _selectionSheetContext;

  MapSelectionController get _controller =>
      _ref.read(mapSelectionControllerProvider.notifier);

  MapSelectionState get _state => _ref.read(mapSelectionControllerProvider);

  Future<void> clearSelectedLocation({bool dismissSheet = true}) async {
    if (dismissSheet &&
        _state.isSelectionSheetOpen &&
        _selectionSheetContext != null) {
      Navigator.of(_selectionSheetContext!).pop(false);
      await _waitForSelectionSheetToClose();
    }

    _controller.resetSelection();
  }

  Future<void> beginDestinationSelection(
    BuildContext context,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
  ) async {
    final start = _state.selectedLatLng;
    if (start == null) {
      await clearSelectedLocation(dismissSheet: false);
      return;
    }

    _controller.setSelectingDestination(true);
    _controller.setDestinationLatLng(null);
    await moveCamera(start, zoom: 6);
    final loc = AppLocalizations.of(context)!;
    _showSnackBar(context, loc.map_select_location_destination_tip);
  }

  Future<void> finishDestinationFlow() async {
    await clearSelectedLocation(dismissSheet: false);
  }

  Future<QuickRoadTripResult?> handleDestinationSelection(
    BuildContext context,
    LatLng position,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
  ) async {
    if (!_state.isSelectingDestination || _state.isSelectionSheetOpen) {
      return null;
    }
    _controller.setDestinationLatLng(position);
    await moveCamera(position, zoom: 12);
    HapticFeedback.lightImpact();
    return showDestinationSelectionSheet(context, moveCamera);
  }

  Future<void> showStartLocationSheet(
    BuildContext context,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
  ) async {
    if (_state.selectedLatLng == null || _state.isSelectionSheetOpen) {
      return;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final paddingValue = 320.0 + bottomInset;

    final proceed = await _presentSelectionSheet<bool>(
      context: context,
      expandedPadding: paddingValue,
      builder: (sheetContext, collapsedNotifier) {
        return StartLocationSheet(
          positionListenable: _controller.selectedLatLngListenable,
          onConfirm: () => Navigator.of(sheetContext).pop(true),
          onCancel: () => Navigator.of(sheetContext).pop(false),
          reverseGeocode: _controller.reverseGeocode,
          fetchNearbyPlaces: _controller.getNearbyPlaces,
          collapsedListenable: collapsedNotifier,
          onExpand: () => collapsedNotifier.value = false,
        );
      },
    );

    if (proceed ?? false) {
      await beginDestinationSelection(context, moveCamera);
    } else {
      await clearSelectedLocation(dismissSheet: false);
    }
  }

  Future<QuickRoadTripResult?> showDestinationSelectionSheet(
    BuildContext context,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
  ) async {
    if (!_state.isSelectingDestination ||
        _state.selectedLatLng == null ||
        _state.destinationLatLng == null) {
      return null;
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final paddingValue = 360.0 + bottomInset;

    final result = await _presentSelectionSheet<QuickRoadTripResult>(
      context: context,
      expandedPadding: paddingValue,
      builder: (sheetContext, collapsedNotifier) {
        return DestinationSelectionSheet(
          startPositionListenable: _controller.selectedLatLngListenable,
          destinationListenable: _controller.destinationLatLngListenable,
          reverseGeocode: _controller.reverseGeocode,
          fetchNearbyPlaces: _controller.getNearbyPlaces,
          collapsedListenable: collapsedNotifier,
          onExpand: () => collapsedNotifier.value = false,
          onCancel: () => Navigator.of(sheetContext).pop(null),
        );
      },
    );

    if (result == null) {
      await finishDestinationFlow();
      return null;
    }

    if (result.openDetailed) {
      await _openDetailedEditor(context);
      await finishDestinationFlow();
      return null;
    }

    await finishDestinationFlow();
    return result;
  }

  Future<QuickRoadTripResult?> handleLongPress(
    BuildContext context,
    LatLng latLng,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
    Future<void> Function() hideEventCard,
  ) async {
    if (_state.isSelectingDestination) {
      return handleDestinationSelection(context, latLng, moveCamera);
    }
    hideEventCard();
    await clearSelectedLocation();
    _controller.setSelectedLatLng(latLng);
    await moveCamera(latLng, zoom: 17);
    await showStartLocationSheet(context, moveCamera);
    return null;
  }

  Future<void> waitForSelectionSheetToClose() => _waitForSelectionSheetToClose();

  Future<void> _waitForSelectionSheetToClose() async {
    var attempts = 0;
    while (_state.isSelectionSheetOpen && attempts < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      attempts++;
    }
  }

  Future<T?> _presentSelectionSheet<T>({
    required BuildContext context,
    required double expandedPadding,
    required Widget Function(
      BuildContext sheetContext,
      ValueNotifier<bool> collapsedNotifier,
    )
        builder,
  }) async {
    final media = MediaQuery.of(context);
    final collapsedHeight = media.size.height * 0.15;
    final collapsedPadding = EdgeInsets.only(bottom: collapsedHeight);
    final expandedEdgeInsets = EdgeInsets.only(bottom: expandedPadding);
    final collapsedNotifier = ValueNotifier<bool>(false);

    void updatePadding() {
      final isCollapsed = collapsedNotifier.value;
      _controller.setMapPadding(
        isCollapsed ? collapsedPadding : expandedEdgeInsets,
      );
    }

    _controller.setSelectionSheetOpen(true);
    _controller.setMapPadding(expandedEdgeInsets);
    collapsedNotifier.addListener(updatePadding);

    T? result;
    try {
      result = await Navigator.of(context).push<T>(
        PageRouteBuilder<T>(
          opaque: false,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (routeContext, animation, secondaryAnimation) {
            return CollapsibleSheetRouteContent<T>(
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
      _controller.resetMapPadding();
      _controller.setSelectionSheetOpen(false);
    }

    return result;
  }

  Future<void> _openDetailedEditor(BuildContext context) async {
    await Navigator.of(context).pushNamed('/roadTripEditor');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

final mapSelectionFlowProvider = Provider.autoDispose(MapSelectionFlow.new);

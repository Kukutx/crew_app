import 'dart:collection';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
class MapSelectionState {
  const MapSelectionState({
    this.selectedLatLng,
    this.destinationLatLng,
    this.isSelectingDestination = false,
    this.isSelectionSheetOpen = false,
    this.mapPadding = EdgeInsets.zero,
  });

  final LatLng? selectedLatLng;
  final LatLng? destinationLatLng;
  final bool isSelectingDestination;
  final bool isSelectionSheetOpen;
  final EdgeInsets mapPadding;

  MapSelectionState copyWith({
    LatLng? selectedLatLng,
    bool selectedLatLngSet = false,
    LatLng? destinationLatLng,
    bool destinationLatLngSet = false,
    bool? isSelectingDestination,
    bool? isSelectionSheetOpen,
    EdgeInsets? mapPadding,
  }) {
    return MapSelectionState(
      selectedLatLng:
          selectedLatLngSet ? selectedLatLng : this.selectedLatLng,
      destinationLatLng:
          destinationLatLngSet ? destinationLatLng : this.destinationLatLng,
      isSelectingDestination:
          isSelectingDestination ?? this.isSelectingDestination,
      isSelectionSheetOpen:
          isSelectionSheetOpen ?? this.isSelectionSheetOpen,
      mapPadding: mapPadding ?? this.mapPadding,
    );
  }
}

class MapSelectionController extends StateNotifier<MapSelectionState> {
  MapSelectionController(this._ref) : super(const MapSelectionState());

  final Ref _ref;
  final ValueNotifier<LatLng?> _selectedLatLngNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<LatLng?> _destinationLatLngNotifier =
      ValueNotifier<LatLng?>(null);
  final Map<String, Future<List<NearbyPlace>>> _nearbyPlacesCache =
      HashMap<String, Future<List<NearbyPlace>>>();

  ValueNotifier<LatLng?> get selectedLatLngListenable =>
      _selectedLatLngNotifier;
  ValueNotifier<LatLng?> get destinationLatLngListenable =>
      _destinationLatLngNotifier;

  PlacesService get _placesService =>
      _ref.read(placesServiceProvider);

  void setSelectedLatLng(LatLng? position) {
    _selectedLatLngNotifier.value = position;
    state = state.copyWith(
      selectedLatLng: position,
      selectedLatLngSet: true,
    );
    if (position == null) {
      setDestinationLatLng(null);
    }
  }

  void setDestinationLatLng(LatLng? position) {
    _destinationLatLngNotifier.value = position;
    state = state.copyWith(
      destinationLatLng: position,
      destinationLatLngSet: true,
    );
  }

  void setSelectingDestination(bool value) {
    state = state.copyWith(isSelectingDestination: value);
  }

  void setSelectionSheetOpen(bool value) {
    state = state.copyWith(isSelectionSheetOpen: value);
  }

  void setMapPadding(EdgeInsets padding) {
    state = state.copyWith(mapPadding: padding);
  }

  void resetMapPadding() {
    state = state.copyWith(mapPadding: EdgeInsets.zero);
  }

  void resetSelection() {
    setSelectingDestination(false);
    setSelectedLatLng(null);
    setDestinationLatLng(null);
  }

  Future<List<NearbyPlace>> getNearbyPlaces(LatLng position) {
    final key = _cacheKey(position);
    final cached = _nearbyPlacesCache[key];
    if (cached != null) {
      return cached;
    }

    final future = _loadNearbyPlaces(position).then(
      (value) => value,
      onError: (Object error, StackTrace stackTrace) {
        _nearbyPlacesCache.remove(key);
        throw error;
      },
    );
    _nearbyPlacesCache[key] = future;
    return future;
  }

  void clearNearbyPlacesCache() {
    _nearbyPlacesCache.clear();
  }

  String _cacheKey(LatLng position) {
    return '${position.latitude.toStringAsFixed(5)}_${position.longitude.toStringAsFixed(5)}';
  }

  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng position) async {
    final results = await _placesService.searchNearbyPlaces(
      position,
      radius: 150,
      maxResults: 6,
    );
    return results.take(3).toList(growable: false);
  }

  @override
  void dispose() {
    _selectedLatLngNotifier.dispose();
    _destinationLatLngNotifier.dispose();
    super.dispose();
  }
}

final mapSelectionControllerProvider =
    StateNotifierProvider.autoDispose<MapSelectionController, MapSelectionState>(
  (ref) => MapSelectionController(ref),
);

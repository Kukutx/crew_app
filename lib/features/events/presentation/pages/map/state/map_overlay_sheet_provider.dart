import 'package:flutter_riverpod/legacy.dart';

enum MapOverlaySheetType {
  none,
  explore,
  chat,
  createRoadTrip,
  createCityEvent,
}

final mapOverlaySheetProvider =
    StateProvider<MapOverlaySheetType>((ref) => MapOverlaySheetType.none);

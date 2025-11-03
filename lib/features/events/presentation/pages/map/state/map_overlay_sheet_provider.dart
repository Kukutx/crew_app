import 'package:flutter_riverpod/legacy.dart';

enum MapOverlaySheetType {
  none,
  explore,
  chat,
  roadTripCreate,
}

final mapOverlaySheetProvider =
    StateProvider<MapOverlaySheetType>((ref) => MapOverlaySheetType.none);

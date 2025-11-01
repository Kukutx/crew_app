import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapOverlaySheetType {
  none,
  explore,
  chat,
}

final mapOverlaySheetProvider =
    StateProvider<MapOverlaySheetType>((ref) => MapOverlaySheetType.none);

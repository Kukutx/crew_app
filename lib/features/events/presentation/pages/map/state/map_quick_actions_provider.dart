import 'package:flutter_riverpod/legacy.dart';

enum MapQuickAction {
  startQuickTrip,
  showMomentSheet,
  viewHistory,
}

final mapQuickActionProvider =
    StateProvider<MapQuickAction?>((ref) => null);

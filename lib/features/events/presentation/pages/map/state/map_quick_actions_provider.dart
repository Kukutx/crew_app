import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapQuickAction {
  startQuickTrip,
  showMomentSheet,
}

final mapQuickActionProvider =
    StateProvider<MapQuickAction?>((ref) => null);

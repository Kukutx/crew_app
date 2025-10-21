import 'package:flutter_riverpod/legacy.dart';

enum MapQuickAction {
  startQuickTrip,
}

final mapQuickActionProvider =
    StateProvider<MapQuickAction?>((ref) => null);

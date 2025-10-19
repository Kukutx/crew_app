import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum MapQuickAction {
  startQuickTrip,
  showMomentSheet,
}

final mapQuickActionProvider =
    StateProvider<MapQuickAction?>((ref) => null);

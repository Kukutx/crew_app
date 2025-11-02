import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapOverlaySheetStage {
  collapsed,
  middle,
  expanded,
}

final mapOverlaySheetStageProvider = StateProvider<MapOverlaySheetStage>(
  (ref) => MapOverlaySheetStage.collapsed,
);

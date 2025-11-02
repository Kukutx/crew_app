import 'package:flutter_riverpod/legacy.dart';

enum MapOverlaySheetStage {
  collapsed,
  middle,
  expanded,
}

final mapOverlaySheetStageProvider = StateProvider<MapOverlaySheetStage>(
  (ref) => MapOverlaySheetStage.collapsed,
);

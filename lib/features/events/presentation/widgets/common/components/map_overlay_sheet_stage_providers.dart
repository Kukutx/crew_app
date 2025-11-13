import 'package:flutter_riverpod/legacy.dart';

enum MapOverlaySheetStage {
  collapsed,
  middle,
  expanded,
}

final mapOverlaySheetStageProvider = StateProvider<MapOverlaySheetStage>(
  (ref) => MapOverlaySheetStage.collapsed,
);

/// Sheet 当前高度比例（0.0 - 1.0）
final mapOverlaySheetSizeProvider = StateProvider<double>(
  (ref) => 0.0,
);


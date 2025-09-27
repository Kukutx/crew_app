import 'package:flutter_riverpod/legacy.dart';

/// Records the current index of the app overlay [PageView].
///
/// The overlay defaults to showing the map tab (index `1`).
final appOverlayIndexProvider = StateProvider<int>((ref) => 1);

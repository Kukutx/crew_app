import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Records the current index of the app overlay [PageView].
///
/// The overlay defaults to showing the map tab (index `0`).
final appOverlayIndexProvider = StateProvider<int>((ref) => 0);


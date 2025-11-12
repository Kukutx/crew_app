import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scroll_activity_provider.dart';

class ScrollActivityListener extends ConsumerStatefulWidget {
  const ScrollActivityListener({
    super.key,
    required this.child,
    this.listenToPointerActivity = false,
  });

  final Widget child;
  final bool listenToPointerActivity;

  @override
  ConsumerState<ScrollActivityListener> createState() => _ScrollActivityListenerState();
}

class _ScrollActivityListenerState extends ConsumerState<ScrollActivityListener> {
  bool _pointerActive = false;

  bool _handleNotification(ScrollNotification notification) {
    final notifier = ref.read(scrollActivityProvider.notifier);
    if (notification is ScrollStartNotification) {
      notifier.updateScrollActivity(true);
    } else if (notification is ScrollEndNotification) {
      notifier.updateScrollActivity(false);
    }
    return false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.listenToPointerActivity) {
      return;
    }
    _pointerActive = true;
    ref.read(scrollActivityProvider.notifier).updateScrollActivity(true);
  }

  void _handlePointerEnd() {
    if (!widget.listenToPointerActivity || !_pointerActive) {
      return;
    }
    _pointerActive = false;
    ref.read(scrollActivityProvider.notifier).updateScrollActivity(false);
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;
    if (widget.listenToPointerActivity) {
      result = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        onPointerCancel: (_) => _handlePointerEnd(),
        onPointerUp: (_) => _handlePointerEnd(),
        child: result,
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: result,
    );
  }
}

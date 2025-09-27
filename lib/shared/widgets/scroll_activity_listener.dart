import 'package:flutter/widgets.dart';

typedef ScrollActivityChangedCallback = void Function(bool isScrolling);

class ScrollActivityListener extends StatefulWidget {
  const ScrollActivityListener({
    super.key,
    required this.onScrollActivityChanged,
    required this.child,
    this.listenToPointerActivity = false,
  });

  final ScrollActivityChangedCallback onScrollActivityChanged;
  final Widget child;
  final bool listenToPointerActivity;

  @override
  State<ScrollActivityListener> createState() => _ScrollActivityListenerState();
}

class _ScrollActivityListenerState extends State<ScrollActivityListener> {
  bool _pointerActive = false;

  bool _handleNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      widget.onScrollActivityChanged(true);
    } else if (notification is ScrollEndNotification) {
      widget.onScrollActivityChanged(false);
    }
    return false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.listenToPointerActivity) {
      return;
    }
    _pointerActive = true;
    widget.onScrollActivityChanged(true);
  }

  void _handlePointerEnd() {
    if (!widget.listenToPointerActivity || !_pointerActive) {
      return;
    }
    _pointerActive = false;
    widget.onScrollActivityChanged(false);
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

import 'package:flutter/widgets.dart';

typedef ScrollActivityChangedCallback = void Function(bool isScrolling);

class ScrollActivityListener extends StatelessWidget {
  const ScrollActivityListener({
    super.key,
    required this.onScrollActivityChanged,
    required this.child,
  });

  final ScrollActivityChangedCallback onScrollActivityChanged;
  final Widget child;

  bool _handleNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      onScrollActivityChanged(true);
    } else if (notification is ScrollEndNotification) {
      onScrollActivityChanged(false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: child,
    );
  }
}

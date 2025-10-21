import 'package:flutter/material.dart';

class CollapsibleSheetRouteContent<T> extends StatelessWidget {
  const CollapsibleSheetRouteContent({
    super.key,
    required this.animation,
    required this.collapsedNotifier,
    required this.builder,
    required this.onBackgroundTap,
  });

  final Animation<double> animation;
  final ValueNotifier<bool> collapsedNotifier;
  final Widget Function(BuildContext context) builder;
  final VoidCallback onBackgroundTap;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(curved);

    final sheet = Builder(
      builder: builder,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: collapsedNotifier,
              builder: (context, collapsed, _) {
                return IgnorePointer(
                  ignoring: collapsed,
                  child: FadeTransition(
                    opacity: curved,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBackgroundTap,
                      child: Container(
                        color: collapsed
                            ? Colors.transparent
                            : Colors.black.withValues(alpha: .45),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: slide,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: collapsedNotifier,
                    builder: (context, collapsed, child) {
                      final height = MediaQuery.of(context).size.height;
                      const collapsedFactor = 0.15;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        constraints: BoxConstraints(
                          minHeight: collapsed ? height * collapsedFactor : 0,
                          maxHeight: height,
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: FractionallySizedBox(
                            heightFactor: collapsed ? collapsedFactor : null,
                            widthFactor: 1,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: sheet,
    );
  }
}

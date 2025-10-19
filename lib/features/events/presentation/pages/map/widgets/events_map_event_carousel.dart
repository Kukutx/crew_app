import 'dart:ui';

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/map_event_floating_card.dart';
import 'package:crew_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EventsMapEventCarousel extends StatelessWidget {
  const EventsMapEventCarousel({
    super.key,
    required this.events,
    required this.visible,
    required this.controller,
    required this.safeBottom,
    required this.onPageChanged,
    required this.onOpenDetails,
    required this.onClose,
    required this.onRegister,
    required this.onFavorite,
  });

  final List<Event> events;
  final bool visible;
  final PageController controller;
  final double safeBottom;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Event> onOpenDetails;
  final VoidCallback onClose;
  final VoidCallback onRegister;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassBackgroundTheme>();
    final blurSigma = glass?.blurSigma ?? 18;
    final opacity = glass?.opacity ?? 0.92;

    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchOutCurve: Curves.easeIn,
          switchInCurve: Curves.easeOutCubic,
          child: !visible || events.isEmpty
              ? const SizedBox.shrink()
              : SizedBox.expand(
                  child: DraggableScrollableSheet(
                    key: ValueKey(events.length),
                    minChildSize: 0.22,
                    initialChildSize: 0.28,
                    maxChildSize: 0.62,
                    snap: true,
                    snapSizes: const [0.28, 0.46, 0.62],
                    builder: (context, scrollController) {
                      return Padding(
                        padding:
                            EdgeInsets.fromLTRB(16, 0, 16, safeBottom.clamp(0, 24) + 12),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: blurSigma,
                              sigmaY: blurSigma,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface
                                    .withOpacity(opacity.clamp(0.6, 0.98)),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withOpacity(0.12),
                                ),
                              ),
                              child: ListView(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                                children: [
                                  Center(
                                    child: Container(
                                      width: 44,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Nearby activities',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: onClose,
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 240,
                                    child: PageView.builder(
                                      controller: controller,
                                      physics: events.length > 1
                                          ? const PageScrollPhysics()
                                          : const NeverScrollableScrollPhysics(),
                                      onPageChanged: onPageChanged,
                                      itemCount: events.length,
                                      itemBuilder: (_, index) {
                                        final event = events[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: MapEventFloatingCard(
                                            key: ValueKey(event.id),
                                            event: event,
                                            onTap: () => onOpenDetails(event),
                                            onClose: onClose,
                                            onRegister: onRegister,
                                            onFavorite: onFavorite,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (events.length > 1) ...[
                                    const SizedBox(height: 12),
                                    _CarouselIndicator(
                                      controller: controller,
                                      itemCount: events.length,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _CarouselIndicator extends StatefulWidget {
  const _CarouselIndicator({
    required this.controller,
    required this.itemCount,
    required this.color,
  });

  final PageController controller;
  final int itemCount;
  final Color color;

  @override
  State<_CarouselIndicator> createState() => _CarouselIndicatorState();
}

class _CarouselIndicatorState extends State<_CarouselIndicator> {
  double _page = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handlePageChanged);
    _page = widget.controller.page ?? widget.controller.initialPage.toDouble();
  }

  @override
  void didUpdateWidget(covariant _CarouselIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handlePageChanged);
      widget.controller.addListener(_handlePageChanged);
      _page = widget.controller.page ?? widget.controller.initialPage.toDouble();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handlePageChanged);
    super.dispose();
  }

  void _handlePageChanged() {
    if (!mounted) return;
    setState(() {
      _page = widget.controller.page ?? widget.controller.initialPage.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final indicators = List.generate(widget.itemCount, (index) {
      final selected = (_page.round() == index);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 6,
        width: selected ? 24 : 8,
        decoration: BoxDecoration(
          color: selected
              ? widget.color
              : widget.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(999),
        ),
      );
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }
}

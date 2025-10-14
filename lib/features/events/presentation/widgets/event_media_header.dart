import 'dart:ui' as ui;

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_media_carousel.dart';
import 'package:flutter/material.dart';

class EventMediaHeader extends StatelessWidget {
  const EventMediaHeader({
    super.key,
    required this.event,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.heroTag,
    required this.stretchAnimation,
    required this.topPadding,
    required this.baseHeight,
    required this.extraStretchHeight,
    required this.maxCornerRadius,
    required this.hasMedia,
    required this.mediaCount,
    required this.onTap,
    required this.onDragEnd,
  });

  final Event event;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String heroTag;
  final Animation<double> stretchAnimation;
  final double topPadding;
  final double baseHeight;
  final double extraStretchHeight;
  final double maxCornerRadius;
  final bool hasMedia;
  final int mediaCount;
  final VoidCallback onTap;
  final ValueChanged<double> onDragEnd;

  @override
  Widget build(BuildContext context) {
    if (!hasMedia) {
      final height = topPadding + baseHeight;
      return Semantics(
        label: event.title,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: _buildCarousel(context, height: height - topPadding),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: stretchAnimation,
      builder: (context, child) {
        final progress = stretchAnimation.value.clamp(0.0, 1.0);
        final height = topPadding + baseHeight + extraStretchHeight * progress;
        final radius = (0.6 - progress).clamp(0.0, 1.0) * maxCornerRadius;
        final opacity = ui.lerpDouble(0.25, 0.8, progress) ?? 0.25;
        final overlayKey = ValueKey<int>((progress * 20).round());
        final semanticsValue = '$currentPageDisplay of $mediaCount';

        return Semantics(
          label: event.title,
          value: semanticsValue,
          button: true,
          child: GestureDetector(
            onTap: onTap,
            onVerticalDragEnd: (details) => onDragEnd(details.primaryVelocity ?? 0),
            child: Hero(
              tag: heroTag,
              flightShuttleBuilder: (_, animation, __, ___, toHero) {
                return FadeTransition(opacity: animation, child: toHero.widget);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: height,
                      width: double.infinity,
                      child: _buildCarousel(context, height: height),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: _GradientOverlay(
                            key: overlayKey,
                            height: topPadding + 72,
                            opacity: opacity,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String get currentPageDisplay {
    if (!hasMedia || mediaCount == 0) {
      return '0';
    }
    final nextIndex = currentPage + 1;
    if (nextIndex <= 1) {
      return '1';
    }
    if (nextIndex >= mediaCount) {
      return mediaCount.toString();
    }
    return nextIndex.toString();
  }

  Widget _buildCarousel(BuildContext context, {double? height}) {
    return Semantics(
      value: hasMedia ? '$currentPageDisplay of $mediaCount' : null,
      child: EventMediaCarousel(
        event: event,
        controller: pageController,
        currentPage: currentPage,
        onPageChanged: onPageChanged,
        height: height,
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({
    super.key,
    required this.height,
    required this.opacity,
  });

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = (theme.colorScheme.scrim).withOpacity(opacity.clamp(0, 1));
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [overlayColor, Colors.transparent],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_image_placeholder.dart';
import 'package:flutter/material.dart';

class EventImageCarousel extends StatelessWidget {
  final Event event;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const EventImageCarousel({
    super.key,
    required this.event,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final images = event.imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    final fallbackUrl = event.firstAvailableImageUrl;
    final hasImages = images.isNotEmpty;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: PageView.builder(
            controller: controller,
            itemCount: hasImages ? images.length : 1,
            onPageChanged: onPageChanged,
            itemBuilder: (_, index) {
              final imageUrl = hasImages ? images[index] : fallbackUrl;
              if (imageUrl == null) {
                return const EventImagePlaceholder(aspectRatio: 16 / 10);
              }
              return CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentPage
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

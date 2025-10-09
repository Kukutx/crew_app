import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/event.dart';
import '../detail/events_detail_page.dart';
import 'event_image_placeholder.dart';

/// A reusable grid card for displaying [Event] items inside masonry layouts.
class EventGridCard extends StatelessWidget {
  const EventGridCard({
    super.key,
    required this.event,
    required this.heroTag,
    this.onShowOnMap,
  });

  final Event event;
  final String heroTag;
  final ValueChanged<Event>? onShowOnMap;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final memCacheW = ((mq.size.width / 2) * mq.devicePixelRatio).round();
    final imageUrl = event.firstAvailableImageUrl;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<Event>(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailPage(event: event),
            ),
          );
          if (result != null) {
            onShowOnMap?.call(result);
          }
        },
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Hero(
                tag: heroTag,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: memCacheW,
                        placeholder: (c, _) => const AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (c, _, _) =>
                            const EventImagePlaceholder(aspectRatio: 1),
                      )
                    : const EventImagePlaceholder(aspectRatio: 1),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

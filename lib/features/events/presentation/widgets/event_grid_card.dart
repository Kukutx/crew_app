import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

import '../../data/event.dart';
import '../pages/detail/events_detail_page.dart';
import 'event_image_cache_manager.dart';
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

  void _onFavoriteTap(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final message =
        loc?.feature_not_ready ?? 'This feature is under development.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final memCacheW = ((mq.size.width / 2) * mq.devicePixelRatio).round();
    final imageUrl = event.firstAvailableImageUrl;

    return Material(
      elevation: 0,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<Event>(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
          if (result != null) {
            onShowOnMap?.call(result);
          }
        },
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: heroTag,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          cacheKey: event.id,
                          cacheManager: EventImageCacheManager.instance,
                          useOldImageOnUrlChange: true,
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
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _onFavoriteTap(context),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        event.isFavorite ? Icons.star : Icons.star_border,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // 待看
              Positioned(
                top: 8,
                left: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      "招募中",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),

              // 标题
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_image_placeholder.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/state/app/app_overlay_provider.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/state/event_map_state/events_providers.dart';
import '../detail/events_detail_page.dart';

class EventsListPage extends ConsumerStatefulWidget {
  const EventsListPage({super.key});

  @override
  ConsumerState<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends ConsumerState<EventsListPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

    // 刷新列表
    ref.listen<AsyncValue<List<Event>>>(eventsProvider, (prev, next) {
      next.whenOrNull(error: (error, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final msg = _errorMessage(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        });
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text(loc.events_title)),
      body: RefreshIndicator(
        onRefresh: () async => await ref.refresh(eventsProvider.future),
        child: eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return _CenteredScrollable(child: Text(loc.no_events));
            }

            return MasonryGridView.count(
              padding: const EdgeInsets.all(8),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: events.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, i) => EventGridItem(
                event: events[i],
                index: i,
                onShowOnMap: (event) {
                  ref.read(appOverlayIndexProvider.notifier).state = 1;
                  ref.read(mapFocusEventProvider.notifier).state = event;
                },
              ),
            );
          },
          loading: () =>
              const _CenteredScrollable(child: CircularProgressIndicator()),
          error: (_, _) => _CenteredScrollable(child: Text(loc.load_failed)),
        ),
      ),
    );
  }
}

String _errorMessage(Object error) {
  if (error is ApiException) {
    return error.message.isNotEmpty ? error.message : error.toString();
  }
  final msg = error.toString();
  return msg.isEmpty ? 'Unknown error' : msg;
}

class _CenteredScrollable extends StatelessWidget {
  final Widget child;

  const _CenteredScrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ],
        );
      },
    );
  }
}

// Flutter idiomatic 的 GridItem
class EventGridItem extends StatelessWidget {
  final Event event;
  final int index;
  final ValueChanged<Event>? onShowOnMap;

  const EventGridItem({
    required this.event,
    required this.index,
    this.onShowOnMap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final memCacheW = ((mq.size.width / 2) * mq.devicePixelRatio).round();
    final heroTag = 'event_$index';
     // Tips： 判断imageUrls是否有值，否则用coverImageUrl
    // (这是当前后端的问题，因为目前后端只有在创建的时候才会自动赋值coverImageUrl，而用SeedDataService预先插入的数据没用自动首页逻辑)，日后待看获取直接用event.coverImageUrl
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
    );
  }
}

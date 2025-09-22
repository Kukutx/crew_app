import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final cachedEvents = eventsAsync.valueOrNull;

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
            return _EventsFeed(
              events: events,
              loc: loc,
            );
          },
          loading: () {
            if (cachedEvents != null) {
              return _EventsFeed(
                events: cachedEvents,
                loc: loc,
                isRefreshing: true,
              );
            }
            return const _CenteredScrollable(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, __) {
            if (cachedEvents != null) {
              return _EventsFeed(
                events: cachedEvents,
                loc: loc,
                errorMessage: _errorMessage(error),
              );
            }
            return _CenteredScrollable(child: Text(loc.load_failed));
          },
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

  const EventGridItem({required this.event, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final memCacheW = ((mq.size.width / 2) * mq.devicePixelRatio).round();
    final heroTag = 'event_$index';
     // Tips： 判断imageUrls是否有值，否则用coverImageUrl
    // (这是当前后端的问题，因为目前后端只有在创建的时候才会自动赋值coverImageUrl，而用SeedDataService预先插入的数据没用自动首页逻辑)，日后待看获取直接用event.coverImageUrl
    final imageUrl = (event.imageUrls.isNotEmpty)
        ? event.imageUrls.first
        : event.coverImageUrl;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
        },
        child: Stack(
          children: [
            Hero(
              tag: heroTag,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: memCacheW,
                placeholder: (c, _) => const AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (c, _, __) => const AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
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

class _EventsFeed extends StatelessWidget {
  final List<Event> events;
  final AppLocalizations loc;
  final bool isRefreshing;
  final String? errorMessage;

  const _EventsFeed({
    required this.events,
    required this.loc,
    this.isRefreshing = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final base = events.isEmpty
        ? _CenteredScrollable(child: Text(loc.no_events))
        : MasonryGridView.count(
            padding: const EdgeInsets.all(8),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: events.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) =>
                EventGridItem(event: events[i], index: i),
          );

    final overlays = <Widget>[];
    if (isRefreshing) {
      overlays.add(const _LoadingOverlay());
    }
    if (errorMessage != null) {
      overlays.add(_MessageBanner(message: errorMessage!));
    }

    if (overlays.isEmpty) return base;

    return Stack(
      children: [
        Positioned.fill(child: base),
        ...overlays,
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: RefreshProgressIndicator(),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;

  const _MessageBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

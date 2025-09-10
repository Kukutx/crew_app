import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/network/api_service.dart';
import '../detail/events_detail_page.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  static const _demoImgs = <String>[
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
    'https://images.unsplash.com/photo-1520975928316-56c6f6f163a4',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba',
    'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?ixlib=rb-1.2.1',
  ];

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: FutureBuilder<List<Event>>(
        future: api.getEvents(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final events = snap.data ?? const <Event>[];
          if (events.isEmpty) {
            return const Center(child: Text('暂无活动'));
          }

          // 用固定的示例图片轮流给 event 配图
          final items = List.generate(events.length, (i) {
            final ev = events[i];
            final img = _demoImgs[i % _demoImgs.length];
            return _GridItem(event: ev, imageUrl: img, index: i);
          });

          return MasonryGridView.count(
            padding: const EdgeInsets.all(8),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: items.length,
            itemBuilder: (context, i) => items[i].build(context),
          );
        },
      ),
    );
  }
}

class _GridItem {
  final Event event;
  final String imageUrl;
  final int index;

  _GridItem({required this.event, required this.imageUrl, required this.index});

  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final memCacheW = ((mq.size.width / 2) * mq.devicePixelRatio).round();
    final heroTag = 'event_$index';

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
                imageUrl: '$imageUrl?w=800',
                fit: BoxFit.cover,
                memCacheWidth: memCacheW,
                placeholder: (c, _) => const AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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

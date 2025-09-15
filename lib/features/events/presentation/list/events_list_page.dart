import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/network/api_service.dart';
import '../detail/events_detail_page.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

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

          return MasonryGridView.count(
            padding: const EdgeInsets.all(8),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: events.length,
            itemBuilder: (context, i) => _GridItem(event: events[i], index: i).build(context),
          );
        },
      ),
    );
  }
}

class _GridItem {
  final Event event;
  final int index;

  _GridItem({required this.event, required this.index});

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

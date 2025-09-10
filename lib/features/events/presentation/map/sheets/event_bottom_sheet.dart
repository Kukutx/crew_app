// sheets/event_bottom_sheet.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/events_detail_page.dart';
import 'package:flutter/material.dart';

/// 地图报名页 事件
void showEventBottomSheet(
    {required BuildContext context, required Event event}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: ListView(
            controller: controller,
            children: [
              // 卡片
              Material(
                color: Colors.white,
                elevation: 0,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 缩略图
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: CachedNetworkImage(
                            imageUrl: /* ev.coverAsset ?? */
                                'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66', // 默认图地址
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (_, __, ___) =>
                                const Center(child: Icon(Icons.error)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 文本区
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题 + 收藏
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context); // 先收起
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EventDetailPage(
                                                    event: event),
                                              ));
                                        },
                                        child: Text(event.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.favorite_border),
                                      onPressed: () {
                                        // TODO: 收藏
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text('收藏 待开发')));
                                      },
                                    ),
                                  ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.place,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(event.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black54))),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                _smallChip('正在报名中'),
                                const SizedBox(width: 6),
                                const Icon(Icons.groups,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 2),
                                const Text(/*ev.peopleText ?? */ '3-5人',
                                    style: TextStyle(color: Colors.black54)),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.event,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                const Text(/*ev.timeText ??*/ '12月28日 8:00',
                                    style: TextStyle(color: Colors.black87)),
                                const Spacer(),
                                SizedBox(
                                  height: 36,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      // TODO: 报名逻辑
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('报名功能未实现')));
                                    },
                                    child: const Text('立即报名'),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    ]),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _smallChip(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Color(0xFFFFE7C2), borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Colors.black87)),
    );

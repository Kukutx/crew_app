import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/events_map_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // 本地占位图（先用你的素材图，后续可换成 event.imageUrls）
  final List<String> _assets = const [
    'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66',
    'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66',
    'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66',
  ];

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {}, // TODO: 分享
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {}, // TODO: 收藏
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 报名逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('报名'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部图片轮播 + 状态胶囊
            Stack(
              children: [
AspectRatio(
  aspectRatio: 16 / 9,
  child: PageView.builder(
    controller: _pageCtrl,
    itemCount: _assets.length,
    onPageChanged: (i) => setState(() => _page = i),
    itemBuilder: (_, i) => CachedNetworkImage(
      imageUrl: _assets[i], // 改成网络图片 URL
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error),
      ),
    ),
  ),
),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('正在报名中',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ),
                // 简单指示点
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _assets.length,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 标题 / 标签 / 描述
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _tagChip('城市探索'),
                      _tagChip('轻松社交'),
                      _tagChip('步行友好'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 活动详情（时间/人数等可先占位；地点可点进地图）
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('活动详情',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _detailRow(Icons.calendar_today, '活动时间', '待公布'),
                  _detailRow(Icons.people, '参与人数', '待公布'),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventsMapPage(selectedEvent: event), // 你的原逻辑
                        ),
                      );
                    },
                    child: _detailRow(Icons.place, '集合地点', widget.event.location),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // 给底部按钮留空间
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.orange)),
      );

  Widget _detailRow(IconData icon, String title, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      );
}

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/map/events_map_page.dart';
import 'package:crew_app/features/user/presentation/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // 示例用户（可换成 event.organizer / backend 返回的用户）
  final _host = (
    name: 'Luca B.',
    bio: 'Milan · 徒步/咖啡/摄影',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
    userId: 'user_123'
  );

  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // 状态栏图标深色
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // TODO: 分享逻辑
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('收藏逻辑 待开发')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // TODO: 收藏逻辑
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('收藏逻辑 待开发')));
            },
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '正在报名中',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: 收藏逻辑
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('收藏逻辑 待开发')));
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 报名逻辑
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('报名逻辑 待开发')));
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
                  aspectRatio: 16 / 10,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: widget.event.imageUrls.isNotEmpty
                        ? widget.event.imageUrls.length
                        : 1,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final imageUrl = widget.event.imageUrls.isNotEmpty
                          ? widget.event.imageUrls[i]
                          : widget.event.coverImageUrl; // 如果没有 imageUrls，用封面图
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

                // 简单指示点
                if (widget.event.imageUrls.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.event.imageUrls.length,
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
            const SizedBox(height: 16),

            // === 新增：主办方/用户信息卡 ===
            const SizedBox(height: 10),

            _userCard(
              name: _host.name,
              bio: _host.bio,
              avatarUrl: _host.avatar,
              onTapProfile: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            UserProfilePage(/*userId: _host.userId*/)));
              },
              onFollow: () async {
                // TODO: 在这里对接后端/Firestore 关注逻辑
                setState(() => _following = !_following);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_following ? '已关注' : '已取消关注')),
                );
              },
              isFollowing: _following,
            ),

            const SizedBox(height: 10),

            // 标题 / 标签 / 描述
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _tagChip('城市探索'),
                        _tagChip('轻松社交'),
                        _tagChip('步行友好'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.description,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 活动详情（时间/人数等可先占位；地点可点进地图）
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('活动详情',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
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
                      child: _detailRow(
                          Icons.place, '集合地点', widget.event.location),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // 给底部按钮留空间
          ],
        ),
      ),
    );
  }

  // 用户信息卡片
  Widget _userCard({
    required String name,
    required String bio,
    required String avatarUrl,
    required VoidCallback onTapProfile,
    required VoidCallback onFollow,
    required bool isFollowing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTapProfile,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: CachedNetworkImageProvider(avatarUrl),
                backgroundColor: Colors.orange.shade50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: isFollowing
                    ? OutlinedButton.icon(
                        onPressed: onFollow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Following'),
                      )
                    : ElevatedButton.icon(
                        onPressed: onFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: const Text('Follow'),
                      ),
              ),
            ],
          ),
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

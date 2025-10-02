import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/user/presentation/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final loc = AppLocalizations.of(context)!;
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
            onPressed: () => _showShareSheet(loc, event),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // TODO: 收藏逻辑
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
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
              child: Text(
                loc.registration_open,
                style: const TextStyle(color: Colors.white, fontSize: 14),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.feature_not_ready)));
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
                        SnackBar(
                            content: Text(loc.registration_not_implemented)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(loc.action_register),
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
              loc: loc,
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
                  SnackBar(
                    content: Text(_following ? loc.followed : loc.unfollowed),
                  ),
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
                        _tagChip(loc.tag_city_explore),
                        _tagChip(loc.tag_easy_social),
                        _tagChip(loc.tag_walk_friendly),
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
                    Text(loc.event_details_title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    const SizedBox(height: 12),
                    _detailRow(Icons.calendar_today, loc.event_time_title,
                        loc.to_be_announced),
                    _detailRow(Icons.people, loc.event_participants_title,
                        loc.to_be_announced),
                    InkWell(
                      onTap: () => Navigator.pop(context, widget.event),
                      child: _detailRow(Icons.place,
                          loc.event_meeting_point_title, widget.event.location),
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
    required AppLocalizations loc,
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
                        label: Text(loc.action_following),
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
                        label: Text(loc.action_follow),
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

  void _showShareSheet(AppLocalizations loc, Event event) {
    final shareUrl = 'https://crew.app/events/${event.id}';
    final shareMessage =
        loc.share_event_message(eventTitle: event.title, shareUrl: shareUrl);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    loc.share_event_title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.ios_share),
                  title: Text(loc.share_option_system),
                  onTap: () async {
                    Navigator.pop(context);
                    await Share.share(shareMessage);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(loc.share_option_wechat),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareToWeChat(loc, shareMessage);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.whatsapp),
                  title: Text(loc.share_option_whatsapp),
                  onTap: () async {
                    Navigator.pop(context);
                    await _shareToWhatsApp(loc, shareMessage);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link),
                  title: Text(loc.share_option_copy_link),
                  onTap: () async {
                    Navigator.pop(context);
                    await Clipboard.setData(ClipboardData(text: shareUrl));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.share_copy_success)),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareToWeChat(
      AppLocalizations loc, String shareMessage) async {
    await Clipboard.setData(ClipboardData(text: shareMessage));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.share_copy_success)),
    );

    final weChatUri = Uri.parse('weixin://');
    if (await canLaunchUrl(weChatUri)) {
      await launchUrl(weChatUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.share_app_not_installed(appName: loc.share_option_wechat),
          ),
        ),
      );
    }
  }

  Future<void> _shareToWhatsApp(
      AppLocalizations loc, String shareMessage) async {
    final encoded = Uri.encodeComponent(shareMessage);
    final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.share_app_not_installed(appName: loc.share_option_whatsapp),
          ),
        ),
      );
    }
  }

}

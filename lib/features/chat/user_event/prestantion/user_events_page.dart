import 'package:flutter/material.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key});

  @override
  State<UserEventsPage> createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  int _tab = 1; // 0=我喜欢的 1=我报名的

  final fakeEvents = [
    {
      "title": "春天一起去爬山吧！",
      "status": "报名中",
      "time": "15:25",
      "subtitle": "不要忘带保温壶",
      "tags": ["户外", "运动"],
      "unread": 3
    },
    {
      "title": "线上听歌小组",
      "status": "进行中",
      "time": "11:20",
      "subtitle": "王聪聪：开门！开门！开门！",
      "tags": ["音乐"],
      "unread": 2
    },
    {
      "title": "米兰市区City Walk 2号",
      "status": "报名中",
      "time": "16:26",
      "subtitle": "米兰小巷：我们征集下一条路线~",
      "tags": ["社交", "旅行"],
      "unread": 0
    },
  ];

  @override
  Widget build(BuildContext context) {
    // final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('我的活动')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/bg_pattern.png"), // 自己放个淡色图
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.85),
              BlendMode.srcATop,
            ),
          ),
        ),
        child: Column(
          children: [
            // 顶部 Tab
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TabChip(
                    label: '我喜欢的',
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                    icon: Icons.favorite,
                  ),
                  const SizedBox(width: 12),
                  _TabChip(
                    label: '我报名的',
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                    icon: Icons.autorenew,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: fakeEvents.length,
                itemBuilder: (context, i) {
                  final ev = fakeEvents[i];
                  return _EventTile(
                    title: ev["title"] as String,
                    subTitle: ev["subtitle"] as String,
                    status: ev["status"] as String,
                    timeText: ev["time"] as String,
                    tags: (ev["tags"] as List).cast<String>(),
                    unreadCount: ev["unread"] as int,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶部 Tab Chip
class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.primary : color.surfaceContainerHighest ,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? color.onPrimary : color.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color.onPrimary : color.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个活动卡片
class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.title,
    required this.subTitle,
    this.tags,
    this.status,
    this.timeText,
    this.unreadCount,
  });

  final String title;
  final String subTitle;
  final List<String>? tags;
  final String? status;
  final String? timeText;
  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: .3))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.surfaceContainerHighest ,
            child: const Icon(Icons.event, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(status!, style: TextStyle(fontSize: 11, color: cs.onSecondaryContainer)),
                      ),
                    const SizedBox(width: 8),
                    Text(timeText ?? '', style: TextStyle(fontSize: 12, color: cs.outline)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subTitle, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                if (tags != null && tags!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      children: tags!
                          .map((e) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest ,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(e, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
          if ((unreadCount ?? 0) > 0)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: cs.error, shape: BoxShape.circle),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(color: cs.onError, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}













// import 'package:crew_app/features/events/data/event.dart';
// import 'package:flutter/material.dart';
// import '../../../core/network/api_service.dart';
// import 'events_detail_page.dart';

// class EventsListPage extends StatefulWidget {
//   const EventsListPage({super.key});
//   @override
//   State<EventsListPage> createState() => _EventsListPageState();
// }

// class _EventsListPageState extends State<EventsListPage> {
//   final api = ApiService();
//   int _tab = 1; // 0=我喜欢的 1=我报名的（仅UI切换，数据过滤按你业务加）

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(centerTitle: true, title: const Text('我的活动')),
//       body: FutureBuilder<List<Event>>(
//         future: api.getEvents(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
//           final events = snap.data ?? const <Event>[];
//           if (events.isEmpty) return const Center(child: Text('暂无活动'));

//           return CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                   child: Row(
//                     children: [
//                       _TabChip(
//                         label: '我喜欢的',
//                         selected: _tab == 0,
//                         onTap: () => setState(() => _tab = 0),
//                         icon: Icons.favorite,
//                       ),
//                       const SizedBox(width: 12),
//                       _TabChip(
//                         label: '我报名的',
//                         selected: _tab == 1,
//                         onTap: () => setState(() => _tab = 1),
//                         icon: Icons.autorenew, // 旋转图标的感觉
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverList.builder(
//                 itemCount: events.length,
//                 itemBuilder: (context, i) {
//                   final ev = events[i];
//                   return _EventTile(
//                     title: ev.title,
//                     subTitle: ev.location,
//                     // 以下字段按需映射：若你的 Event 没有就传 null/忽略
//                     cover: (ev as dynamic).coverUrl,           // String?
//                     organizer: (ev as dynamic).organizerName,   // String?
//                     tags: (ev as dynamic).tags as List<String>?,// List<String>?
//                     status: (ev as dynamic).status,             // 例：'报名中' '进行中' '已结束'
//                     timeText: (ev as dynamic).timeText,         // 例：'15:25'
//                     unreadCount: (ev as dynamic).unreadCount,   // int?
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => EventDetailPage(event: ev)),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// /// 顶部 Tab Chip
// class _TabChip extends StatelessWidget {
//   const _TabChip({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//     required this.icon,
//   });
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//   final IconData icon;

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     return InkWell(
//       borderRadius: BorderRadius.circular(24),
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: selected ? color.primary : color.surfaceContainerHighest,
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 16, color: selected ? color.onPrimary : color.onSurfaceVariant),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: selected ? color.onPrimary : color.onSurface,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// 单行活动卡片（贴近你截图的结构）
// class _EventTile extends StatelessWidget {
//   const _EventTile({
//     required this.title,
//     required this.subTitle,
//     this.cover,
//     this.organizer,
//     this.tags,
//     this.status,
//     this.timeText,
//     this.unreadCount,
//     this.onTap,
//   });

//   final String title;
//   final String subTitle;
//   final String? cover;
//   final String? organizer;
//   final List<String>? tags;
//   final String? status;
//   final String? timeText;
//   final int? unreadCount;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 左侧封面/头像
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: SizedBox(
//                 width: 44,
//                 height: 44,
//                 child: cover != null && cover!.isNotEmpty
//                     ? Image.network(cover!, fit: BoxFit.cover)
//                     : Container(color: cs.surfaceContainerHighest, child: const Icon(Icons.image, size: 20)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // 中间内容
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 标题 + 状态胶囊
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//                         ),
//                       ),
//                       if (status != null && status!.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           margin: const EdgeInsets.only(left: 6),
//                           decoration: BoxDecoration(
//                             color: cs.secondaryContainer,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(status!, style: TextStyle(fontSize: 11, color: cs.onSecondaryContainer)),
//                         ),
//                       const SizedBox(width: 8),
//                       // 时间
//                       Text(timeText ?? '', style: TextStyle(fontSize: 12, color: cs.outline)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   // 组织者/副标题
//                   Text(
//                     organizer != null && organizer!.isNotEmpty ? organizer! : subTitle,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
//                   ),
//                   const SizedBox(height: 6),
//                   // 标签
//                   if (tags != null && tags!.isNotEmpty)
//                     Wrap(
//                       spacing: 6,
//                       runSpacing: -6,
//                       children: tags!
//                           .take(3)
//                           .map((e) => Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: cs.surfaceContainerHighest,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(e, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
//                               ))
//                           .toList(),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             // 右侧未读气泡
//             if ((unreadCount ?? 0) > 0)
//               Badge(
//                 label: Text('${unreadCount!}'),
//                 largeSize: 20,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

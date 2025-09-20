import 'package:crew_app/features/chat/group_chat/presentation/group_chat_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key});

  @override
  State<UserEventsPage> createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  int _tab = 1; // 0=我喜欢的 1=我报名的

  final List<Map<String, Object>> _fakeEvents = [
    {
      'title': '春天一起去爬山吧！',
      'status': '报名中',
      'time': '15:25',
      'subtitle': '不要忘带保温壶',
      'tags': ['户外', '运动'],
      'unread': 3,
    },
    {
      'title': '线上听歌小组',
      'status': '进行中',
      'time': '11:20',
      'subtitle': '王聪聪：开门！开门！开门！',
      'tags': ['音乐'],
      'unread': 2,
    },
    {
      'title': '米兰市区City Walk 2号',
      'status': '报名中',
      'time': '16:26',
      'subtitle': '米兰小巷：我们征集下一条路线~',
      'tags': ['社交', '旅行'],
      'unread': 0,
    },
  ];

  late final GroupParticipant _currentUser = GroupParticipant(
    name: '我',
    initials: 'ME',
    avatarColor: const Color(0xFF6750A4),
    isSelf: true,
  );

  late final List<List<GroupParticipant>> _sampleParticipants = [
    [
      const GroupParticipant(
        name: '林雨晴',
        initials: 'YQ',
        avatarColor: Color(0xFF6750A4),
      ),
      const GroupParticipant(
        name: 'Marco',
        initials: 'MA',
        avatarColor: Color(0xFF4C6ED7),
      ),
      const GroupParticipant(
        name: '王聪聪',
        initials: 'CC',
        avatarColor: Color(0xFFE46C5B),
      ),
    ],
    [
      const GroupParticipant(
        name: 'Leo',
        initials: 'LE',
        avatarColor: Color(0xFF00696B),
      ),
      const GroupParticipant(
        name: 'Cici',
        initials: 'CI',
        avatarColor: Color(0xFFD6589F),
      ),
      const GroupParticipant(
        name: 'Hannah',
        initials: 'HA',
        avatarColor: Color(0xFFB1974B),
      ),
    ],
    [
      const GroupParticipant(
        name: '米兰小巷',
        initials: 'ML',
        avatarColor: Color(0xFF2F4858),
      ),
      const GroupParticipant(
        name: 'Francesca',
        initials: 'FR',
        avatarColor: Color(0xFFB75F89),
      ),
      const GroupParticipant(
        name: 'Ken',
        initials: 'KE',
        avatarColor: Color(0xFF377D71),
      ),
    ],
  ];

  late final List<List<GroupMessage>> _sampleMessages = [
    [
      GroupMessage(
        sender: _sampleParticipants[0][0],
        content: '周六记得带上登山杖和保温壶，山上还会有些冷。',
        timeLabel: '09:20',
        replyCount: 3,
        replyPreview: '王聪聪：收到！',
        attachmentChips: const ['行程安排.pdf'],
      ),
      GroupMessage(
        sender: _sampleParticipants[0][2],
        content: '我可以带两壶热姜茶，大家可以分着喝。',
        timeLabel: '10:02',
      ),
      GroupMessage(
        sender: _currentUser,
        content: '太贴心了！下午三点在龙泉寺门口集合哦～',
        timeLabel: '10:05',
      ),
    ],
    [
      GroupMessage(
        sender: _sampleParticipants[1][0],
        content: '今晚 8 点开始，提前十分钟上线试一下音频～',
        timeLabel: '15:40',
        replyCount: 2,
      ),
      GroupMessage(
        sender: _sampleParticipants[1][1],
        content: '我准备了新的歌单，等会分享链接。',
        timeLabel: '15:44',
      ),
      GroupMessage(
        sender: _currentUser,
        content: '我能顺便点几首老歌吗？',
        timeLabel: '15:46',
      ),
    ],
    [
      GroupMessage(
        sender: _sampleParticipants[2][0],
        content: '路线 2 号有一些石板路，记得穿好走的鞋子。',
        timeLabel: '08:12',
        attachmentChips: const ['路线图.png'],
      ),
      GroupMessage(
        sender: _sampleParticipants[2][1],
        content: '咖啡店会提前预约，大家提前 10 分钟到哦。',
        timeLabel: '08:21',
      ),
      GroupMessage(
        sender: _currentUser,
        content: '收到，我顺便把城市探索的新朋友拉进来了。',
        timeLabel: '08:30',
      ),
    ],
  ];

  void _openChat(Map<String, Object> event, int index) {
    final participants = _sampleParticipants[index % _sampleParticipants.length];
    final messages = _sampleMessages[index % _sampleMessages.length];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          channelTitle: event['title'] as String,
          participants: participants,
          currentUser: _currentUser,
          initialMessages: messages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(loc.my_events),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            tooltip: loc.filter,
            onPressed: () {},
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_pattern.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.9),
              BlendMode.srcATop,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TabChip(
                    label: loc.events_tab_favorites,
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                    icon: Icons.favorite,
                  ),
                  const SizedBox(width: 12),
                  _TabChip(
                    label: loc.events_tab_registered,
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                    icon: Icons.autorenew,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: _fakeEvents.length,
                itemBuilder: (context, index) {
                  final ev = _fakeEvents[index];
                  return _EventTile(
                    title: ev['title'] as String,
                    subTitle: ev['subtitle'] as String,
                    status: ev['status'] as String,
                    timeText: ev['time'] as String,
                    tags: (ev['tags'] as List).cast<String>(),
                    unreadCount: ev['unread'] as int,
                    highlightColor: cs.primary,
                    openChatLabel: loc.events_open_chat,
                    onTap: () => _openChat(ev, index),
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
          color: selected ? color.primary : color.surfaceContainerHighest,
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
    required this.tags,
    required this.highlightColor,
    required this.openChatLabel,
    this.status,
    this.timeText,
    this.unreadCount,
    this.onTap,
  });

  final String title;
  final String subTitle;
  final List<String> tags;
  final Color highlightColor; 
  final String openChatLabel;
  final String? status;
  final String? timeText;
  final int? unreadCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: cs.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: highlightColor.withValues(alpha: .12),
                          child: Icon(Icons.forum_outlined, color: highlightColor),
                        ),
                        if ((unreadCount ?? 0) > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: TextStyle(
                                  color: cs.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (status != null)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                          ),
                          if (tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: tags
                                    .map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeText ?? '',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 18),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: cs.onSurfaceVariant.withOpacity(.7)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 18, color: highlightColor),
                    const SizedBox(width: 6),
                    Text(
                      openChatLabel,
                      style: TextStyle(
                        color: highlightColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.push_pin_outlined, size: 18, color: cs.onSurfaceVariant.withOpacity(.6)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

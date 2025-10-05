import 'package:crew_app/features/chat/group_chat/data/group_message.dart';
import 'package:crew_app/features/chat/group_chat/data/group_participant.dart';
import 'package:crew_app/features/chat/group_chat/presentation/group_chat_page.dart';
import 'package:crew_app/features/chat/user_event/data/user_event.dart';
import 'package:crew_app/features/chat/user_event/presentation/widgets/user_events_favorites_grid.dart';
import 'package:crew_app/features/chat/user_event/presentation/widgets/user_events_registered_list.dart';
import 'package:crew_app/features/chat/user_event/presentation/widgets/user_events_tab_bar.dart';
export 'package:crew_app/features/chat/user_event/presentation/widgets/user_event_list_tile.dart';
export 'package:crew_app/features/chat/user_event/presentation/widgets/user_event_tab_chip.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key});

  @override
  State<UserEventsPage> createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  int _tab = 1; // 0=我喜欢的 1=我报名的

  late final List<UserEventPreview> _sampleEvents = [
    const UserEventPreview(
      title: '春天一起去爬山吧！',
      status: '报名中',
      timeText: '15:25',
      subtitle: '不要忘带保温壶',
      tags: ['户外', '运动'],
      unreadCount: 3,
      accentColor: Color(0xFF6750A4),
    ),
    const UserEventPreview(
      title: '线上听歌小组',
      status: '进行中',
      timeText: '11:20',
      subtitle: '王聪聪：开门！开门！开门！',
      tags: ['音乐'],
      unreadCount: 2,
      accentColor: Color(0xFF4C6ED7),
    ),
    const UserEventPreview(
      title: '米兰市区City Walk 2号',
      status: '报名中',
      timeText: '16:26',
      subtitle: '米兰小巷：我们征集下一条路线~',
      tags: ['社交', '旅行'],
      unreadCount: 0,
      accentColor: Color(0xFF377D71),
    ),
  ];

  late final GroupParticipant _currentUser = GroupParticipant(
    name: '我',
    initials: 'ME',
    avatarColor: const Color(0xFF6750A4),
    isSelf: true,
  );

  late final List<List<GroupParticipant>> _sampleParticipants = [
    const [
      GroupParticipant(
        name: '林雨晴',
        initials: 'YQ',
        avatarColor: Color(0xFF6750A4),
      ),
      GroupParticipant(
        name: 'Marco',
        initials: 'MA',
        avatarColor: Color(0xFF4C6ED7),
      ),
      GroupParticipant(
        name: '王聪聪',
        initials: 'CC',
        avatarColor: Color(0xFFE46C5B),
      ),
    ],
    const [
      GroupParticipant(
        name: 'Leo',
        initials: 'LE',
        avatarColor: Color(0xFF00696B),
      ),
      GroupParticipant(
        name: 'Cici',
        initials: 'CI',
        avatarColor: Color(0xFFD6589F),
      ),
      GroupParticipant(
        name: 'Hannah',
        initials: 'HA',
        avatarColor: Color(0xFFB1974B),
      ),
    ],
    const [
      GroupParticipant(
        name: '米兰小巷',
        initials: 'ML',
        avatarColor: Color(0xFF2F4858),
      ),
      GroupParticipant(
        name: 'Francesca',
        initials: 'FR',
        avatarColor: Color(0xFFB75F89),
      ),
      GroupParticipant(
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

  void _openChat(UserEventPreview event, int index) {
    final participants =
        _sampleParticipants[index % _sampleParticipants.length];
    final messages = _sampleMessages[index % _sampleMessages.length];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          channelTitle: event.title,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: UserEventsTabBar(
              selectedIndex: _tab,
              favoritesLabel: loc.events_tab_favorites,
              registeredLabel: loc.events_tab_registered,
              onChanged: (value) => setState(() => _tab = value),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _tab == 0
                  ? UserEventsFavoritesGrid(
                      key: const ValueKey('favorites'),
                      events: _sampleEvents,
                      onEventTap: (index) =>
                          _openChat(_sampleEvents[index], index),
                    )
                  : UserEventsRegisteredList(
                      key: const ValueKey('registered'),
                      events: _sampleEvents,
                      onEventTap: (index) =>
                          _openChat(_sampleEvents[index], index),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

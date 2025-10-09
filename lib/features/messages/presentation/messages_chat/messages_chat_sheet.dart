import 'package:crew_app/features/messages/data/messages_chat_message.dart';
import 'package:crew_app/features/messages/data/messages_chat_participant.dart';
import 'package:crew_app/features/messages/data/messages_chat_preview.dart';
import 'package:crew_app/features/messages/data/messages_chat_private_preview.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/messages_direct_chat_page.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_private_list.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_registered_list.dart';
import 'package:crew_app/features/messages/presentation/messages_chat_room/messages_chat_room_page.dart';
export 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_list_tile.dart';
export 'package:crew_app/shared/widgets/toggle_tab_chip.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MessagesChatSheet extends StatefulWidget {
  const MessagesChatSheet({super.key});

  @override
  State<MessagesChatSheet> createState() => _MessagesChatSheetState();
}

class _MessagesChatSheetState extends State<MessagesChatSheet> {
  int _tab = 0;

  late final TextEditingController _searchController;
  String _searchQuery = '';

  late final List<MessagesChatPrivatePreview> _samplePrivateConversations = const [
    MessagesChatPrivatePreview(
      name: '李想',
      subtitle: '要不要晚上一起吃饭？',
      timestamp: '16:45',
      initials: 'LX',
      avatarColor: Color(0xFF4C6ED7),
      isUnread: true,
    ),
    MessagesChatPrivatePreview(
      name: 'Marco',
      subtitle: 'Ci vediamo domani in coworking?',
      timestamp: '15:12',
      initials: 'MA',
      avatarColor: Color(0xFF6750A4),
      isActive: true,
    ),
    MessagesChatPrivatePreview(
      name: '王聪聪',
      subtitle: '我已经把资料发给你啦～',
      timestamp: '昨天',
      initials: 'CC',
      avatarColor: Color(0xFFE46C5B),
    ),
    MessagesChatPrivatePreview(
      name: 'Sara',
      subtitle: 'Grazie per报名活动！',
      timestamp: '周一',
      initials: 'SA',
      avatarColor: Color(0xFF377D71),
      isUnread: true,
    ),
  ];

  late final MessagesChatParticipant _currentUser = MessagesChatParticipant(
    name: '我',
    initials: 'ME',
    avatarColor: const Color(0xFF6750A4),
    isSelf: true,
  );

  late final List<MessagesChatParticipant> _privateContacts = _samplePrivateConversations
      .map(
        (conversation) => MessagesChatParticipant(
          name: conversation.name,
          initials: _resolveInitials(
            conversation.name,
            conversation.initials,
          ),
          avatarColor: conversation.avatarColor ?? const Color(0xFF6750A4),
        ),
      )
      .toList(growable: false);

  late final List<List<MessagesChatMessage>> _samplePrivateMessages = [
    [
      MessagesChatMessage(
        sender: _privateContacts[0],
        content: '今晚想吃川菜还是意面？',
        timeLabel: '16:40',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: '川菜吧，我下班去你那边找你～',
        timeLabel: '16:42',
      ),
      MessagesChatMessage(
        sender: _privateContacts[0],
        content: '好，那我提前预约。',
        timeLabel: '16:44',
      ),
    ],
    [
      MessagesChatMessage(
        sender: _privateContacts[1],
        content: 'Ti mando la presentazione più tardi.',
        timeLabel: '14:55',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: 'Perfetto, grazie! 明早见～',
        timeLabel: '15:01',
      ),
      MessagesChatMessage(
        sender: _privateContacts[1],
        content: 'A domani 👋',
        timeLabel: '15:04',
      ),
    ],
    [
      MessagesChatMessage(
        sender: _privateContacts[2],
        content: '你收到我发的资料了吗？',
        timeLabel: '昨天 19:12',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: '收到了，今晚就开始整理。',
        timeLabel: '昨天 19:20',
      ),
      MessagesChatMessage(
        sender: _privateContacts[2],
        content: '太好了！那我就等你的好消息～',
        timeLabel: '昨天 19:21',
      ),
    ],
    [
      MessagesChatMessage(
        sender: _privateContacts[3],
        content: 'Grazie per l\'invito all\'evento!',
        timeLabel: '周一 10:12',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: '不客气，到时候一起玩～',
        timeLabel: '周一 10:18',
      ),
      MessagesChatMessage(
        sender: _privateContacts[3],
        content: 'Can\'t wait!',
        timeLabel: '周一 10:20',
      ),
    ],
  ];

  late final List<MessagesChatPreview> _sampleEvents = [
    const MessagesChatPreview(
      title: '春天一起去爬山吧！',
      status: '报名中',
      timeText: '15:25',
      subtitle: '不要忘带保温壶',
      tags: ['户外', '运动'],
      unreadCount: 3,
      accentColor: Color(0xFF6750A4),
    ),
    const MessagesChatPreview(
      title: '线上听歌小组',
      status: '进行中',
      timeText: '11:20',
      subtitle: '王聪聪：开门！开门！开门！',
      tags: ['音乐'],
      unreadCount: 2,
      accentColor: Color(0xFF4C6ED7),
    ),
    const MessagesChatPreview(
      title: '米兰市区City Walk 2号',
      status: '报名中',
      timeText: '16:26',
      subtitle: '米兰小巷：我们征集下一条路线~',
      tags: ['社交', '旅行'],
      unreadCount: 0,
      accentColor: Color(0xFF377D71),
    ),
  ];

  late final List<List<MessagesChatParticipant>> _sampleParticipants = [
    const [
      MessagesChatParticipant(
        name: '林雨晴',
        initials: 'YQ',
        avatarColor: Color(0xFF6750A4),
      ),
      MessagesChatParticipant(
        name: 'Marco',
        initials: 'MA',
        avatarColor: Color(0xFF4C6ED7),
      ),
      MessagesChatParticipant(
        name: '王聪聪',
        initials: 'CC',
        avatarColor: Color(0xFFE46C5B),
      ),
    ],
    const [
      MessagesChatParticipant(
        name: 'Leo',
        initials: 'LE',
        avatarColor: Color(0xFF00696B),
      ),
      MessagesChatParticipant(
        name: 'Cici',
        initials: 'CI',
        avatarColor: Color(0xFFD6589F),
      ),
      MessagesChatParticipant(
        name: 'Hannah',
        initials: 'HA',
        avatarColor: Color(0xFFB1974B),
      ),
    ],
    const [
      MessagesChatParticipant(
        name: '米兰小巷',
        initials: 'ML',
        avatarColor: Color(0xFF2F4858),
      ),
      MessagesChatParticipant(
        name: 'Francesca',
        initials: 'FR',
        avatarColor: Color(0xFFB75F89),
      ),
      MessagesChatParticipant(
        name: 'Ken',
        initials: 'KE',
        avatarColor: Color(0xFF377D71),
      ),
    ],
  ];

  late final List<List<MessagesChatMessage>> _sampleMessages = [
    [
      MessagesChatMessage(
        sender: _sampleParticipants[0][0],
        content: '周六记得带上登山杖和保温壶，山上还会有些冷。',
        timeLabel: '09:20',
        replyCount: 3,
        replyPreview: '王聪聪：收到！',
        attachmentChips: const ['行程安排.pdf'],
      ),
      MessagesChatMessage(
        sender: _sampleParticipants[0][2],
        content: '我可以带两壶热姜茶，大家可以分着喝。',
        timeLabel: '10:02',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: '太贴心了！下午三点在龙泉寺门口集合哦～',
        timeLabel: '10:05',
      ),
    ],
    [
      MessagesChatMessage(
        sender: _sampleParticipants[1][0],
        content: '今晚 8 点开始，提前十分钟上线试一下音频～',
        timeLabel: '15:40',
        replyCount: 2,
      ),
      MessagesChatMessage(
        sender: _sampleParticipants[1][1],
        content: '我准备了新的歌单，等会分享链接。',
        timeLabel: '15:44',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: '我能顺便点几首老歌吗？',
        timeLabel: '15:46',
      ),
    ],
    [
      MessagesChatMessage(
        sender: _sampleParticipants[2][0],
        content: '路线 2 号有一些石板路，记得穿好走的鞋子。',
        timeLabel: '08:12',
        attachmentChips: const ['路线图.png'],
      ),
      MessagesChatMessage(
        sender: _sampleParticipants[2][1],
        content: '咖啡店会提前预约，大家提前 10 分钟到哦。',
        timeLabel: '08:21',
      ),
      MessagesChatMessage(
        sender: _currentUser,
        content: '收到，我顺便把城市探索的新朋友拉进来了。',
        timeLabel: '08:30',
      ),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _resolveInitials(String name, [String? provided]) {
    final source = (provided ?? name).trim();
    if (source.isEmpty) {
      return '';
    }
    final codeUnits = source.runes.toList(growable: false);
    final length = codeUnits.length >= 2 ? 2 : 1;
    return String.fromCharCodes(codeUnits.take(length)).toUpperCase();
  }

  void _openPrivateChat(MessagesChatPrivatePreview conversation) {
    final index = _samplePrivateConversations.indexOf(conversation);
    if (index < 0 || index >= _samplePrivateMessages.length) {
      return;
    }

    final partner = _privateContacts[index];
    final messages = _samplePrivateMessages[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessagesDirectChatPage(
          preview: conversation,
          partner: partner,
          currentUser: _currentUser,
          initialMessages: messages,
        ),
      ),
    );
  }

  void _openGroupChat(MessagesChatPreview event) {
    final index = _sampleEvents.indexOf(event);
    final safeIndex = index >= 0 ? index : 0;
    final participants =
        _sampleParticipants[safeIndex % _sampleParticipants.length];
    final messages = _sampleMessages[safeIndex % _sampleMessages.length];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessagesChatRoomPage(
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final query = _searchQuery.trim().toLowerCase();

    List<MessagesChatPrivatePreview> privateResults;
    if (query.isEmpty) {
      privateResults = _samplePrivateConversations;
    } else {
      privateResults = _samplePrivateConversations
          .where(
            (conversation) =>
                conversation.name.toLowerCase().contains(query) ||
                conversation.subtitle.toLowerCase().contains(query),
          )
          .toList(growable: false);
    }

    List<MessagesChatPreview> eventResults;
    if (query.isEmpty) {
      eventResults = _sampleEvents;
    } else {
      eventResults = _sampleEvents
          .where(
            (event) {
              final lowerTitle = event.title.toLowerCase();
              final lowerSubtitle = event.subtitle.toLowerCase();
              final lowerStatus = (event.status ?? '').toLowerCase();
              final tagsMatch = event.tags
                  .any((tag) => tag.toLowerCase().contains(query));
              return lowerTitle.contains(query) ||
                  lowerSubtitle.contains(query) ||
                  lowerStatus.contains(query) ||
                  tagsMatch;
            },
          )
          .toList(growable: false);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
              child: Row(
                children: [
                  Text(
                    loc.group,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: loc.chat_search_hint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.trim().isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ToggleTabBar(
                selectedIndex: _tab,
                firstLabel: loc.events_tab_favorites,
                secondLabel: loc.events_tab_registered,
                onChanged: (value) => setState(() => _tab = value),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _tab == 0
                    ? MessagesChatPrivateList(
                        key: ValueKey('private-$query'),
                        conversations: privateResults,
                        onConversationTap: _openPrivateChat,
                      )
                    : MessagesChatRegisteredList(
                        key: ValueKey('registered-$query'),
                        events: eventResults,
                        onEventTap: _openGroupChat,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

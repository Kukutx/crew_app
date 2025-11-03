import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/data/group_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/chat_room/chat_conversation_page.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/system_notifications_page.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/direct_chat_list.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/group_chat_list.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';

class ChatSheet extends StatefulWidget {
  const ChatSheet({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<ChatSheet> {
  int _tab = 0;

  late final TextEditingController _searchController;
  String _searchQuery = '';

  late final List<DirectChatPreview> _samplePrivateConversations = const [
    DirectChatPreview(
      id: 'direct-system',
      displayName: '系统通知',
      lastMessagePreview: '查看最新公告，不错过任何重要提醒',
      lastMessageTimeLabel: '刚刚',
      isSystem: true,
      hasUnread: true,
    ),
    DirectChatPreview(
      id: 'direct-1',
      displayName: '李想',
      lastMessagePreview: '要不要晚上一起吃饭？',
      lastMessageTimeLabel: '16:45',
      initials: 'LX',
      avatarColorValue: 0xFF4C6ED7,
      hasUnread: true,
    ),
    DirectChatPreview(
      id: 'direct-2',
      displayName: 'Marco',
      lastMessagePreview: 'Ci vediamo domani in coworking?',
      lastMessageTimeLabel: '15:12',
      initials: 'MA',
      avatarColorValue: 0xFF6750A4,
      isActive: true,
    ),
    DirectChatPreview(
      id: 'direct-3',
      displayName: '王聪聪',
      lastMessagePreview: '我已经把资料发给你啦～',
      lastMessageTimeLabel: '昨天',
      initials: 'CC',
      avatarColorValue: 0xFFE46C5B,
    ),
    DirectChatPreview(
      id: 'direct-4',
      displayName: 'Sara',
      lastMessagePreview: 'Grazie per报名活动！',
      lastMessageTimeLabel: '周一',
      initials: 'SA',
      avatarColorValue: 0xFF377D71,
      hasUnread: true,
    ),
  ];

  late final List<DirectChatPreview> _nonSystemPrivateConversations =
      _samplePrivateConversations
          .where((conversation) => !conversation.isSystem)
          .toList(growable: false);

  late final List<DirectChatPreview> _systemPrivateConversations =
      _samplePrivateConversations
          .where((conversation) => conversation.isSystem)
          .toList(growable: false);

  late final ChatParticipant _currentUser = const ChatParticipant(
    id: 'user-me',
    displayName: '我',
    initials: 'ME',
    avatarColorValue: 0xFF6750A4,
    isCurrentUser: true,
  );

  late final List<ChatParticipant> _privateContacts =
      _nonSystemPrivateConversations.map(
        (conversation) => ChatParticipant(
          id: 'direct-participant-${conversation.id}',
          displayName: conversation.displayName,
          initials: _resolveInitials(
            conversation.displayName,
            conversation.initials,
          ),
          avatarColorValue:
              conversation.avatarColorValue ?? _currentUser.avatarColorValue,
        ),
      )
      .toList(growable: false);

  late final Map<String, ChatParticipant> _privateContactsByConversationId =
      Map.fromIterables(
    _nonSystemPrivateConversations.map((conversation) => conversation.id),
    _privateContacts,
  );

  late final List<List<ChatMessage>> _samplePrivateMessages = [
    [
      ChatMessage(
        id: 'direct-1-msg-1',
        sender: _privateContacts[0],
        body: '今晚想吃川菜还是意面？',
        sentAtLabel: '16:40',
      ),
      ChatMessage(
        id: 'direct-1-msg-2',
        sender: _currentUser,
        body: '川菜吧，我下班去你那边找你～',
        sentAtLabel: '16:42',
      ),
      ChatMessage(
        id: 'direct-1-msg-3',
        sender: _privateContacts[0],
        body: '好，那我提前预约。',
        sentAtLabel: '16:44',
      ),
    ],
    [
      ChatMessage(
        id: 'direct-2-msg-1',
        sender: _privateContacts[1],
        body: 'Ti mando la presentazione più tardi.',
        sentAtLabel: '14:55',
      ),
      ChatMessage(
        id: 'direct-2-msg-2',
        sender: _currentUser,
        body: 'Perfetto, grazie! 明早见～',
        sentAtLabel: '15:01',
      ),
      ChatMessage(
        id: 'direct-2-msg-3',
        sender: _privateContacts[1],
        body: 'A domani 👋',
        sentAtLabel: '15:04',
      ),
    ],
    [
      ChatMessage(
        id: 'direct-3-msg-1',
        sender: _privateContacts[2],
        body: '你收到我发的资料了吗？',
        sentAtLabel: '昨天 19:12',
      ),
      ChatMessage(
        id: 'direct-3-msg-2',
        sender: _currentUser,
        body: '收到了，今晚就开始整理。',
        sentAtLabel: '昨天 19:20',
      ),
      ChatMessage(
        id: 'direct-3-msg-3',
        sender: _privateContacts[2],
        body: '太好了！那我就等你的好消息～',
        sentAtLabel: '昨天 19:21',
      ),
    ],
    [
      ChatMessage(
        id: 'direct-4-msg-1',
        sender: _privateContacts[3],
        body: 'Grazie per l\'invito all\'evento!',
        sentAtLabel: '周一 10:12',
      ),
      ChatMessage(
        id: 'direct-4-msg-2',
        sender: _currentUser,
        body: '不客气，到时候一起玩～',
        sentAtLabel: '周一 10:18',
      ),
      ChatMessage(
        id: 'direct-4-msg-3',
        sender: _privateContacts[3],
        body: 'Can\'t wait!',
        sentAtLabel: '周一 10:20',
      ),
    ],
  ];

  late final List<GroupChatPreview> _sampleEvents = const [
    GroupChatPreview(
      id: 'group-1',
      title: '春天一起去爬山吧！',
      status: '报名中',
      lastMessageTimeLabel: '15:25',
      subtitle: '不要忘带保温壶',
      tags: ['户外', '运动'],
      unreadCount: 3,
      accentColorValue: 0xFF6750A4,
    ),
    GroupChatPreview(
      id: 'group-2',
      title: '线上听歌小组',
      status: '进行中',
      lastMessageTimeLabel: '11:20',
      subtitle: '王聪聪：开门！开门！开门！',
      tags: ['音乐'],
      unreadCount: 2,
      accentColorValue: 0xFF4C6ED7,
    ),
    GroupChatPreview(
      id: 'group-3',
      title: '米兰市区City Walk 2号',
      status: '报名中',
      lastMessageTimeLabel: '16:26',
      subtitle: '米兰小巷：我们征集下一条路线~',
      tags: ['社交', '旅行'],
      unreadCount: 0,
      accentColorValue: 0xFF377D71,
    ),
  ];

  late final List<List<ChatParticipant>> _sampleParticipants = [
    const [
      ChatParticipant(
        id: 'group-1-1',
        displayName: '林雨晴',
        initials: 'YQ',
        avatarColorValue: 0xFF6750A4,
      ),
      ChatParticipant(
        id: 'group-1-2',
        displayName: 'Marco',
        initials: 'MA',
        avatarColorValue: 0xFF4C6ED7,
      ),
      ChatParticipant(
        id: 'group-1-3',
        displayName: '王聪聪',
        initials: 'CC',
        avatarColorValue: 0xFFE46C5B,
      ),
    ],
    const [
      ChatParticipant(
        id: 'group-2-1',
        displayName: 'Leo',
        initials: 'LE',
        avatarColorValue: 0xFF00696B,
      ),
      ChatParticipant(
        id: 'group-2-2',
        displayName: 'Cici',
        initials: 'CI',
        avatarColorValue: 0xFFD6589F,
      ),
      ChatParticipant(
        id: 'group-2-3',
        displayName: 'Hannah',
        initials: 'HA',
        avatarColorValue: 0xFFB1974B,
      ),
    ],
    const [
      ChatParticipant(
        id: 'group-3-1',
        displayName: '米兰小巷',
        initials: 'ML',
        avatarColorValue: 0xFF2F4858,
      ),
      ChatParticipant(
        id: 'group-3-2',
        displayName: 'Francesca',
        initials: 'FR',
        avatarColorValue: 0xFFB75F89,
      ),
      ChatParticipant(
        id: 'group-3-3',
        displayName: 'Ken',
        initials: 'KE',
        avatarColorValue: 0xFF377D71,
      ),
    ],
  ];

  late final List<List<ChatMessage>> _sampleMessages = [
    [
      ChatMessage(
        id: 'group-1-msg-1',
        sender: _sampleParticipants[0][0],
        body: '周六记得带上登山杖和保温壶，山上还会有些冷。',
        sentAtLabel: '09:20',
        replyCount: 3,
        replyPreview: '王聪聪：收到！',
        attachmentLabels: const ['行程安排.pdf'],
      ),
      ChatMessage(
        id: 'group-1-msg-2',
        sender: _sampleParticipants[0][2],
        body: '我可以带两壶热姜茶，大家可以分着喝。',
        sentAtLabel: '10:02',
      ),
      ChatMessage(
        id: 'group-1-msg-3',
        sender: _currentUser,
        body: '太贴心了！下午三点在龙泉寺门口集合哦～',
        sentAtLabel: '10:05',
      ),
    ],
    [
      ChatMessage(
        id: 'group-2-msg-1',
        sender: _sampleParticipants[1][0],
        body: '今晚 8 点开始，提前十分钟上线试一下音频～',
        sentAtLabel: '15:40',
        replyCount: 2,
      ),
      ChatMessage(
        id: 'group-2-msg-2',
        sender: _sampleParticipants[1][1],
        body: '我准备了新的歌单，等会分享链接。',
        sentAtLabel: '15:44',
      ),
      ChatMessage(
        id: 'group-2-msg-3',
        sender: _currentUser,
        body: '我能顺便点几首老歌吗？',
        sentAtLabel: '15:46',
      ),
    ],
    [
      ChatMessage(
        id: 'group-3-msg-1',
        sender: _sampleParticipants[2][0],
        body: '路线 2 号有一些石板路，记得穿好走的鞋子。',
        sentAtLabel: '08:12',
        attachmentLabels: const ['路线图.png'],
      ),
      ChatMessage(
        id: 'group-3-msg-2',
        sender: _sampleParticipants[2][1],
        body: '咖啡店会提前预约，大家提前 10 分钟到哦。',
        sentAtLabel: '08:21',
      ),
      ChatMessage(
        id: 'group-3-msg-3',
        sender: _currentUser,
        body: '收到，我顺便把城市探索的新朋友拉进来了。',
        sentAtLabel: '08:30',
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

  void _openSystemNotifications() {
    if (_systemPrivateConversations.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SystemNotificationsPage(
          notifications: _systemPrivateConversations,
        ),
      ),
    );
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

  void _openPrivateChat(DirectChatPreview conversation) {
    if (conversation.isSystem) {
      return;
    }

    final index = _nonSystemPrivateConversations.indexOf(conversation);
    if (index < 0 || index >= _samplePrivateMessages.length) {
      return;
    }

    final partner = _privateContacts[index];
    final messages = _samplePrivateMessages[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationPage.direct(
          preview: conversation,
          partner: partner,
          currentUser: _currentUser,
          initialMessages: messages,
        ),
      ),
    );
  }

  void _openGroupChat(GroupChatPreview event) {
    final index = _sampleEvents.indexOf(event);
    final safeIndex = index >= 0 ? index : 0;
    final participants =
        _sampleParticipants[safeIndex % _sampleParticipants.length];
    final messages = _sampleMessages[safeIndex % _sampleMessages.length];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationPage.group(
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

    List<DirectChatPreview> privateResults;
    if (query.isEmpty) {
      privateResults = _samplePrivateConversations;
    } else {
      privateResults = _samplePrivateConversations
          .where(
            (conversation) =>
                conversation.displayName.toLowerCase().contains(query) ||
                conversation.lastMessagePreview.toLowerCase().contains(query),
          )
          .toList(growable: false);
    }

    List<GroupChatPreview> eventResults;
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

    final privateList = DirectChatList(
      key: ValueKey('private-$query'),
      conversations: privateResults
          .where((conversation) => !conversation.isSystem)
          .toList(growable: false),
      onConversationTap: _openPrivateChat,
      onAvatarTap: (conversation) {
        final participant = _privateContactsByConversationId[conversation.id];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserProfilePage(
              uid: participant?.id ?? conversation.id,
            ),
          ),
        );
      },
      showSectionHeaders: _systemPrivateConversations.isNotEmpty,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 12),
    );

    final groupList = GroupChatList(
      key: ValueKey('registered-$query'),
      events: eventResults,
      onEventTap: _openGroupChat,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 12),
    );

    final scrollable = CustomScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          sliver: SliverToBoxAdapter(
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
        ),
        const SliverToBoxAdapter(child: Divider(height: 1)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          sliver: SliverToBoxAdapter(
            child: ToggleTabBar(
              selectedIndex: _tab,
              firstLabel: loc.messages_tab_private,
              secondLabel: loc.messages_tab_groups,
              onChanged: (value) => setState(() => _tab = value),
              trailingBuilder: (_, _) {
                final hasUnreadNotifications = _systemPrivateConversations
                    .any((conversation) => conversation.hasUnread);
                final canOpenNotifications =
                    _systemPrivateConversations.isNotEmpty;

                return Opacity(
                  opacity: canOpenNotifications ? 1 : 0.6,
                  child: Material(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          canOpenNotifications ? _openSystemNotifications : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            if (hasUnreadNotifications)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          sliver: SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _tab == 0 ? privateList : groupList,
            ),
          ),
        ),
      ],
    );

    return SafeArea(
      top: false,
      bottom: true,
      child: scrollable,
    );
  }
}

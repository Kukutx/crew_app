import 'package:crew_app/features/messages/data/direct_message_preview.dart';
import 'package:crew_app/features/messages/data/direct_message_story.dart';
import 'package:flutter/material.dart';

class DirectMessagesPage extends StatefulWidget {
  const DirectMessagesPage({super.key});

  @override
  State<DirectMessagesPage> createState() => _DirectMessagesPageState();
}

class _DirectMessagesPageState extends State<DirectMessagesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _username = 'zhongi_liu_99';

  final List<DirectMessageStory> _stories = const [
    DirectMessageStory(
      title: '分享新鲜事',
      subtitle: '位置更新',
      gradient: LinearGradient(
        colors: [Color(0xFFFF6F91), Color(0xFFFF9671)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.favorite_border,
      badgeLabel: '+',
      badgeColor: Color(0xFFFFF3E0),
    ),
    DirectMessageStory(
      title: 'Avete un',
      subtitle: 'posto libero?',
      gradient: LinearGradient(
        colors: [Color(0xFF845EC2), Color(0xFFD65DB1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.forum_outlined,
    ),
    DirectMessageStory(
      title: 'Zhuo...',
      subtitle: '聊天',
      gradient: LinearGradient(
        colors: [Color(0xFF008F7A), Color(0xFF2C73D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.map_outlined,
    ),
    DirectMessageStory(
      title: 'Mappa',
      subtitle: '活动',
      gradient: LinearGradient(
        colors: [Color(0xFFFFC75F), Color(0xFFF9F871)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.location_on_outlined,
    ),
    DirectMessageStory(
      title: 'Linda',
      subtitle: '新的内容',
      gradient: LinearGradient(
        colors: [Color(0xFF00C9A7), Color(0xFF92FE9D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.photo_camera_outlined,
    ),
  ];

  final List<DirectMessagePreview> _messages = const [
    DirectMessagePreview(
      name: 'caterina',
      subtitle: 'Attivo/a 33 min fa',
      timestamp: '· Messaggi',
      initials: 'ca',
      avatarColor: Color(0xFFFF9671),
      isActive: true,
      isUnread: true,
    ),
    DirectMessagePreview(
      name: 'Stella',
      subtitle: 'Visualizzato',
      timestamp: '1 h fa',
      initials: 'st',
      avatarColor: Color(0xFF845EC2),
    ),
    DirectMessagePreview(
      name: 'sassyhouseofaccessories',
      subtitle: 'Visualizzato',
      timestamp: '2 h fa',
      initials: 'sa',
      avatarColor: Color(0xFFD65DB1),
    ),
    DirectMessagePreview(
      name: '0.7',
      subtitle: 'Attivo/a oggi',
      timestamp: '· Messaggi',
      initials: '07',
      avatarColor: Color(0xFF2C73D2),
      isActive: true,
    ),
    DirectMessagePreview(
      name: '凌',
      subtitle: 'Ha messo "Mi piace" 5 sett',
      timestamp: '· Messaggi',
      initials: '凌',
      avatarColor: Color(0xFF008F7A),
    ),
    DirectMessagePreview(
      name: 'Celine Zhang',
      subtitle: 'Attivo/a 1 h fa',
      timestamp: '· Messaggi',
      initials: 'CZ',
      avatarColor: Color(0xFFFFC75F),
      isActive: true,
    ),
  ];

  final List<DirectMessagePreview> _requests = const [
    DirectMessagePreview(
      name: 'Marco',
      subtitle: 'Chiede di seguirti',
      timestamp: '· Richiesta',
      initials: 'MA',
      avatarColor: Color(0xFF00C9A7),
      isUnread: true,
    ),
    DirectMessagePreview(
      name: 'Aurora',
      subtitle: 'Puoi unirti al gruppo?',
      timestamp: '· Richiesta',
      initials: 'AU',
      avatarColor: Color(0xFFFF8066),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _username,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_outlined),
            tooltip: 'New message',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            tooltip: 'Camera',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _StoriesSection(stories: _stories),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _DirectMessagesTabBar(controller: _tabController),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MessagesList(messages: _messages),
                _MessagesList(messages: _requests, emptyPlaceholder: _buildEmptyRequests(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequests(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mail_outline,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无新的请求',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '当有人向你发送私信请求时，将会出现在这里',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection({required this.stories});

  final List<DirectMessageStory> stories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final story = stories[index];
          return _StoryCard(story: story);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: stories.length,
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final DirectMessageStory story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: story.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Icon(
                  story.icon ?? Icons.person_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              if (story.badgeLabel != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: story.badgeColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      story.badgeLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          story.title,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (story.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            story.subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _DirectMessagesTabBar extends StatelessWidget {
  const _DirectMessagesTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: theme.textTheme.titleSmall,
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(text: 'Messaggi'),
          Tab(text: 'Richieste'),
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    this.emptyPlaceholder,
  });

  final List<DirectMessagePreview> messages;
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return emptyPlaceholder ?? const SizedBox();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final preview = messages[index];
        return _MessageTile(preview: preview);
      },
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 88, endIndent: 16),
      itemCount: messages.length,
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.preview});

  final DirectMessagePreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = preview.subtitleColor ?? theme.colorScheme.onSurfaceVariant;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      leading: _Avatar(initials: preview.initials, color: preview.avatarColor, isActive: preview.isActive),
      title: Text(
        preview.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: preview.isUnread ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              preview.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: subtitleColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            preview.timestamp,
            style: theme.textTheme.bodyMedium?.copyWith(color: subtitleColor),
          ),
          if (preview.isUnread) ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.photo_camera_outlined),
        onPressed: () {},
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    this.initials,
    this.color,
    this.isActive = false,
  });

  final String? initials;
  final Color? color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color ?? theme.colorScheme.primary,
          child: Text(
            (initials ?? '').toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isActive)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

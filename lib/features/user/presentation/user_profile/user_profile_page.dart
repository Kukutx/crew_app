import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/user_profile/profile_guestbook_provider.dart';
import 'package:crew_app/features/user/presentation/user_profile/user_profile_provider.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/collapsed_profile_avatar.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_header_card.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_tab_view.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_guestbook.dart';
import 'package:crew_app/shared/widgets/app_floating_action_button.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  static const double _expandedHeight = 320;
  static const double _tabBarHeight = 48;

  late final TabController _tabController;
  late int _currentTabIndex;
  final List<Tab> _tabs = const [
    Tab(text: '活动'),
    Tab(text: '收藏'),
    Tab(text: '留言簿'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _currentTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(eventsProvider); 
    await ref.read(eventsProvider.future); 
  }

  void _toggleFollow() {
    final current = ref.read(userProfileProvider);
    ref.read(userProfileProvider.notifier).state = current.copyWith(
      followed: !current.followed,
      followers: current.followed
          ? current.followers - 1
          : current.followers + 1,
    );
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final nextIndex = _tabController.index;
    if (nextIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = nextIndex;
      });
    }
  }

  void _showMoreActions(BuildContext context, User profile) {
    final messenger = ScaffoldMessenger.of(context);
    final link = 'https://crew.app/users/${profile.uid}';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('拉黑'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('已拉黑该用户（示例）')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('举报'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('举报成功（示例）')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制链接'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Clipboard.setData(ClipboardData(text: link));
                  messenger.showSnackBar(
                    SnackBar(content: Text('已复制链接：$link')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startPrivateMessage(BuildContext context, User profile) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => const DirectMessagesPage(),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '私信功能尚未开放，敬请期待！',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  Future<void> _openGuestbookComposer() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ProfileGuestbookComposerSheet(
          onSubmit: (name, content) {
            ref
                .read(profileGuestbookProvider.notifier)
                .addMessage(name, content);
          },
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('留言成功！')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      floatingActionButton: _currentTabIndex == 2
          ? AppFloatingActionButton(
              heroTag: 'user_profile_guestbook_fab',
              margin: EdgeInsets.only(bottom: 120 + bottomPadding, right: 6),
              onPressed: _openGuestbookComposer,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            _buildSliverAppBar(context, profile, topPadding, theme),
          ],
          body: ProfileTabView(controller: _tabController),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    User profile,
    double topPadding,
    ThemeData theme,
  ) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: _expandedHeight,
      automaticallyImplyLeading: widget.onClose == null,
      leading: widget.onClose == null
          ? null
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreActions(context, profile),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          final minExtent = topPadding + kToolbarHeight + _tabBarHeight;
          final maxExtent = topPadding + _expandedHeight;
          final availableExtent = maxExtent - minExtent <= 0
              ? 1.0
              : maxExtent - minExtent;
          final t = ((currentHeight - minExtent) / availableExtent).clamp(
            0.0,
            1.0,
          );
          final collapseProgress = 1 - t;

          return Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: profile.cover, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
              if (t > 0.05)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: lerpDouble(16, 72, t)!,
                  child: Opacity(
                    opacity: Curves.easeOut.transform(t),
                    child: Transform.scale(
                      scale: lerpDouble(0.92, 1, t)!,
                      child: ProfileHeaderCard(
                        userProfile: profile,
                        onFollowToggle: _toggleFollow,
                        onMessagePressed: () =>
                            _startPrivateMessage(context, profile),
                      ),
                    ),
                  ),
                ),
              if (collapseProgress > 0)
                Positioned(
                  top: topPadding + (kToolbarHeight - 48) / 2,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: collapseProgress < 0.6,
                    child: Opacity(
                      opacity: Curves.easeIn.transform(collapseProgress),
                      child: Center(
                        child: CollapsedProfileAvatar(user: profile),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(height: topPadding),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_tabBarHeight),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: _tabs,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});
  @override
  ConsumerState<UserProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  static const double _expandedHeight = 320;
  static const double _tabBarHeight = 48;

  late final TabController _tabCtrl;
  final _tabs = const [Tab(text: '活动'), Tab(text: '收藏')];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.refresh(eventsProvider.future);
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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(_profileProvider);
    final theme = Theme.of(context);
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: _expandedHeight, // 给卡片留空间
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showMoreActions(context, profile),
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, c) {
                  final currentHeight = c.biggest.height;
                  final minExtent =
                      topPad + kToolbarHeight + _tabBarHeight; // 吸顶后的高度
                  final maxExtent = topPad + _expandedHeight;
                  final availableExtent =
                      maxExtent - minExtent <= 0 ? 1.0 : maxExtent - minExtent;
                  final t = ((currentHeight - minExtent) / availableExtent)
                      .clamp(0.0, 1.0);
                  final collapseProgress = 1 - t;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // 封面
                      CachedNetworkImage(
                          imageUrl: profile.cover, fit: BoxFit.cover),
                      // 渐变压暗
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                      // 头像卡片：随滚动淡出，避免折叠时溢出
                      if (t > 0.05)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: lerpDouble(16, 72, t)!,
                          child: Opacity(
                            opacity: Curves.easeOut.transform(t),
                            child: Transform.scale(
                              scale: lerpDouble(0.92, 1, t)!,
                              child: _HeaderCard(userProfile: profile),
                            ),
                          ),
                        ),
                      // 折叠后的头像
                      if (collapseProgress > 0)
                        Positioned(
                          top: topPad + (kToolbarHeight - 48) / 2,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            ignoring: collapseProgress < 0.6,
                            child: Opacity(
                              opacity: Curves.easeIn.transform(collapseProgress),
                              child: Center(
                                child: _CollapsedAvatar(user: profile),
                              ),
                            ),
                          ),
                        ),
                      // 顶部安全区占位，避免被刘海/状态栏压住
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SizedBox(height: topPad)),
                    ],
                  );
                },
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(_tabBarHeight),
                child: Material(
                  color: theme.scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabCtrl,
                    tabs: _tabs,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: const [_ActivitiesGrid(), _FavoritesGrid()],
          ),
        ),
      ),
    );
  }
}

/// ====== 头部卡片（头像、签名、统计、按钮） ======
class _HeaderCard extends ConsumerWidget {
  const _HeaderCard({required this.userProfile});
  final User userProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          // 用 Material 带阴影/表面色
          elevation: 6,
          color: Colors.white.withValues(alpha: 0.12),
          surfaceTintColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: CachedNetworkImage(
                      imageUrl: userProfile.avatar,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle(
                    style: t.bodyMedium!.copyWith(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userProfile.name,
                            style: t.titleMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(userProfile.bio,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(children: [
                          _Stat('粉丝', userProfile.followers),
                          _Dot(),
                          _Stat('关注', userProfile.following),
                          _Dot(),
                          _Stat('活动', userProfile.events),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _FollowButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
                color: Colors.white70, shape: BoxShape.circle)),
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final white = Colors.white;
    return Row(
      children: [
        Text('$value',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: white, fontWeight: FontWeight.w700)),
        const SizedBox(width: 4),
        Text(label,
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(color: white)),
      ],
    );
  }
}

class _FollowButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(_profileProvider);
    final followed = profile.followed;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: followed ? Colors.white10 : Colors.white,
        foregroundColor: followed ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        final current = ref.read(_profileProvider);
        ref.read(_profileProvider.notifier).state = current.copyWith(
          followed: !current.followed,
          followers:
              current.followed ? current.followers - 1 : current.followers + 1,
        );
      },
      child: Text(followed ? '已关注' : '关注'),
    );
  }
}

class _CollapsedAvatar extends StatelessWidget {
  const _CollapsedAvatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(user.avatar),
        ),
      ),
    );
  }
}

/// ====== Tab 内容：活动（瀑布流） ======
class _ActivitiesGrid extends ConsumerWidget {
  const _ActivitiesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (events) {
        final registered = events
            .where((event) => event.isRegistered)
            .toList(growable: false);

        if (registered.isEmpty) {
          return _CenteredScrollable(child: Text(loc.no_events));
        }

        return AppMasonryGrid(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: registered.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final event = registered[index];
            return EventGridCard(
              event: event,
              heroTag: 'profile_activity_${event.id}_$index',
            );
          },
        );
      },
      loading: () =>
          const _CenteredScrollable(child: CircularProgressIndicator()),
      error: (_, __) => _CenteredScrollable(child: Text(loc.load_failed)),
    );
  }
}

/// ====== Tab 内容：收藏（瀑布流） ======
class _FavoritesGrid extends ConsumerWidget {
  const _FavoritesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (events) {
        final favorites = events
            .where((event) => event.isFavorite)
            .toList(growable: false);

        if (favorites.isEmpty) {
          return _CenteredScrollable(child: Text(loc.favorites_empty));
        }

        return AppMasonryGrid(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: favorites.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final event = favorites[index];
            return EventGridCard(
              event: event,
              heroTag: 'profile_favorite_${event.id}_$index',
            );
          },
        );
      },
      loading: () =>
          const _CenteredScrollable(child: CircularProgressIndicator()),
      error: (_, __) => _CenteredScrollable(child: Text(loc.load_failed)),
    );
  }
}

class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ],
        );
      },
    );
  }
}

/// ====== 假数据 Provider ======
final _profileProvider = StateProvider<User>((ref) {
  return User(
    uid: 'u_001',
    name: 'Luna',
    bio: '爱户外、爱分享 | Crew 资深爱好者',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    cover: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
    followers: 1280,
    following: 96,
    events: 345,
    followed: false,
  );
});

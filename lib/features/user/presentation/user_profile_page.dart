import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/data/ActivityItem.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});
  @override
  ConsumerState<UserProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
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

  Future<void> _onRefresh() async =>
      Future<void>.delayed(const Duration(milliseconds: 800));

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(_profileProvider);
    final theme = Theme.of(context);
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 300, // 给卡片留空间
              flexibleSpace: LayoutBuilder(
                builder: (context, c) {
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
                      // 头像卡片：固定在底部，避开刘海（topPad）
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 72, // 留出 TabBar 的高度
                        child: _HeaderCard(userProfile: profile),
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
                preferredSize: const Size.fromHeight(48),
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
            // // 用自己的 Delegate 来做吸顶 TabBar
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: _TabHeaderDelegate(
            //     child: Material(
            //       elevation: 2, // 吸顶时带一点阴影更有层次
            //       color: Theme.of(context).scaffoldBackgroundColor,
            //       child: TabBar(
            //         controller: _tabCtrl,
            //         tabs: _tabs,
            //         indicatorSize: TabBarIndicatorSize.tab,
            //       ),
            //     ),
            //   ),
            // ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: const [_ActivitiesList(), _FavoritesGrid()],
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
                          _Stat('获赞', userProfile.likes),
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

/// ====== Tab 内容：活动（列表） ======
class _ActivitiesList extends ConsumerWidget {
  const _ActivitiesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_activitiesProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = items[i];
        return _ActivityTile(e: e);
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.e});
  final ActivityItem e;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {/* TODO: 跳到活动详情 */},
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14)),
              child: CachedNetworkImage(
                  imageUrl: e.imageUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('${e.location} · ${_fmtDate(e.time)}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// ====== Tab 内容：收藏（瀑布流） ======
class _FavoritesGrid extends ConsumerWidget {
  const _FavoritesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(_favoritesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: images.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: i.isOdd ? 3 / 4 : 1,
            child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// ====== 吸顶 Tab Header Delegate ======
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabHeaderDelegate({required this.child});
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) => false;
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
    likes: 345,
    followed: false,
  );
});

final _activitiesProvider = Provider<List<ActivityItem>>((ref) => List.generate(
      8,
      (i) => ActivityItem(
        id: 'act_$i',
        title: '城市慢跑 #$i',
        imageUrl: 'https://picsum.photos/seed/act$i/300/200',
        time: DateTime.now().subtract(Duration(days: i * 2)),
        location: 'Milan, IT',
      ),
    ));

final _favoritesProvider = Provider<List<String>>((ref) => List.generate(
      12,
      (i) => 'https://picsum.photos/seed/fav$i/400/600',
    ));

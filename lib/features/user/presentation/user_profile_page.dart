import 'dart:ui';

import 'package:crew_app/features/user/data/ActivityItem.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// ====== 主页面 ======
class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});
  @override
  ConsumerState<UserProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  final _tabs = const [
    Tab(text: '作品'),
    Tab(text: '活动'),
    Tab(text: '收藏'),
  ];

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(_profileProvider);
    final tabCtrl = TabController(length: _tabs.length, vsync: this);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerScrolled) => [
            // ===== 背景封面图 =====
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              title: Text(profile.name),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
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
                  ],
                ),
              ),
            ),
            // ===== 用户卡片，悬浮在封面下缘 =====
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HeaderCard(userProfile: profile),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // ===== Tab Header 吸顶 =====
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabHeaderDelegate(
                child: Material(
                  color: theme.scaffoldBackgroundColor,
                  child: TabBar(
                    controller: tabCtrl,
                    tabs: _tabs,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: tabCtrl,
            children: const [
              _PostsGrid(),
              _ActivitiesList(),
              _FavoritesGrid(),
            ],
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
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: CachedNetworkImage(
                  imageUrl: userProfile.avatar,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DefaultTextStyle(
                  style: textTheme.bodyMedium!.copyWith(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.name,
                        style: textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProfile.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Stat('粉丝', userProfile.followers),
                          _Dot(),
                          _Stat('关注', userProfile.following),
                          _Dot(),
                          _Stat('获赞', userProfile.likes),
                        ],
                      ),
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
        // TODO: Firebase：写入/删除 collection('follows').doc(current.uid)...
      },
      child: Text(followed ? '已关注' : '关注'),
    );
  }
}

/// ====== Tab 内容：作品（瀑布流） ======
class _PostsGrid extends ConsumerWidget {
  const _PostsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(_postsProvider);
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
            aspectRatio: i.isEven ? 3 / 4 : 1,
            child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
          ),
        ),
      ),
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


/// ====== 假数据 Provider（替换为 Firestore Stream/FutureProvider 即可） ======
final _profileProvider = StateProvider<User>((ref) {
  return User(
    uid: 'u_001',
    name: 'Luna',
    bio: '爱户外、爱分享 | Crew 资深爱动员',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    cover: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
    followers: 1280,
    following: 96,
    likes: 34500,
    followed: false,
  );
});

final _postsProvider = Provider<List<String>>((ref) => List.generate(
      24,
      (i) =>
          'https://images.unsplash.com/photo-15${30 + i}2192596544-9eb780fc7f66',
    ));

final _activitiesProvider = Provider<List<ActivityItem>>((ref) => List.generate(
      12,
      (i) => ActivityItem(
        id: 'act_$i',
        title: '城市慢跑 #$i',
        imageUrl:
            'https://images.unsplash.com/photo-1520975916090-3105956dac38',
        time: DateTime.now().subtract(Duration(days: i * 3)),
        location: 'Milan, IT',
      ),
    ));

final _favoritesProvider = Provider<List<String>>((ref) => List.generate(
      16,
      (i) =>
          'https://images.unsplash.com/photo-151${40 + i}9255554-9eb780fc7f66',
    ));

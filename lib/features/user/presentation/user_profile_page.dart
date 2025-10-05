import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/data/activity_item.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.refresh(_profileProvider.future),
      ref.refresh(_activitiesProvider.future),
      ref.refresh(_favoritesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_profileProvider);
    final theme = Theme.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    final loc = AppLocalizations.of(context)!;
    final tabs = [
      Tab(text: loc.my_events),
      Tab(text: loc.events_tab_favorites),
    ];
    final profile = profileAsync.valueOrNull;
    final coverUrl = profile?.cover;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: _expandedHeight, // 给卡片留空间
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
                      if (coverUrl != null && coverUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const _DefaultCoverPlaceholder(),
                        )
                      else
                        const _DefaultCoverPlaceholder(),
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
                              child: _HeaderCard(profile: profileAsync),
                            ),
                          ),
                        ),
                      // 折叠后的头像
                      if (collapseProgress > 0 && profile != null)
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
                    tabs: tabs,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
              ),
            ),
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
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final AsyncValue<User> profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          elevation: 6,
          color: Colors.white.withValues(alpha: 0.12),
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: profile.when(
              data: (userProfile) {
                final bio = userProfile.bio?.trim();
                return Row(
                  children: [
                    _ProfileAvatar(avatarUrl: userProfile.avatar),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DefaultTextStyle(
                        style:
                            textTheme.bodyMedium!.copyWith(color: Colors.white),
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
                              (bio != null && bio.isNotEmpty) ? bio : '--',
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
                    const _FollowButton(),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 72,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stack) {
                final message =
                    error is ApiException ? error.message : loc.load_failed;
                return SizedBox(
                  height: 72,
                  child: Center(
                    child: Text(
                      message,
                      style: textTheme.bodyMedium!
                          .copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const _AvatarPlaceholder(size: 64),
        ),
      );
    }
    return const _AvatarPlaceholder(size: 64);
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size),
      ),
      child: const Icon(Icons.person, color: Colors.white70, size: 32),
    );
  }
}

class _FollowButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(_profileProvider);
    final loc = AppLocalizations.of(context)!;
    return profile.when(
      data: (value) {
        final followed = value.followed;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: followed ? Colors.white10 : Colors.white,
            foregroundColor: followed ? Colors.white : Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.feature_not_ready)),
            );
          },
          child: Text(followed ? '已关注' : '关注'),
        );
      },
      loading: () => const SizedBox(
        height: 40,
        width: 96,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, stack) => SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: () => ref.invalidate(_profileProvider),
          child: Text(loc.load_failed),
        ),
      ),
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
          backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: (user.avatar == null || user.avatar!.isEmpty)
              ? const Icon(Icons.person, color: Colors.black54)
              : null,
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
    final activities = ref.watch(_activitiesProvider);
    final loc = AppLocalizations.of(context)!;
    return activities.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildPlaceholderScroll(
            context: context,
            child: Text(loc.history_empty),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final e = items[i];
            return _ActivityTile(item: e);
          },
        );
      },
      loading: () => _buildPlaceholderScroll(
        context: context,
        child: const CircularProgressIndicator(),
      ),
      error: (error, stack) {
        final message =
            error is ApiException ? error.message : loc.load_failed;
        return _buildPlaceholderScroll(
          context: context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => ref.invalidate(_activitiesProvider),
                icon: const Icon(Icons.refresh),
                tooltip: loc.load_failed,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    final metaParts = <String>[];
    final location = item.location?.trim();
    if (location != null && location.isNotEmpty) {
      metaParts.add(location);
    }
    final time = item.time;
    if (time != null) {
      metaParts.add(_fmtDate(time));
    }
    final metaText = metaParts.isEmpty ? '--' : metaParts.join(' · ');

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
              child: SizedBox(
                width: 120,
                height: 90,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const _ActivityImagePlaceholder(),
                      )
                    : const _ActivityImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(
                      metaText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
    final favorites = ref.watch(_favoritesProvider);
    final loc = AppLocalizations.of(context)!;
    return favorites.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildPlaceholderScroll(
            context: context,
            child: Text(loc.favorites_empty),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: MasonryGridView.count(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: events.length,
            itemBuilder: (_, i) {
              final event = events[i];
              final imageUrl = event.firstAvailableImageUrl;
              final aspectRatio = i.isOdd ? 3 / 4 : 1.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const _FavoriteImagePlaceholder(),
                        )
                      : const _FavoriteImagePlaceholder(),
                ),
              );
            },
          ),
        );
      },
      loading: () => _buildPlaceholderScroll(
        context: context,
        child: const CircularProgressIndicator(),
      ),
      error: (error, stack) {
        final message =
            error is ApiException ? error.message : loc.load_failed;
        return _buildPlaceholderScroll(
          context: context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => ref.invalidate(_favoritesProvider),
                icon: const Icon(Icons.refresh),
                tooltip: loc.load_failed,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityImagePlaceholder extends StatelessWidget {
  const _ActivityImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.event,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _FavoriteImagePlaceholder extends StatelessWidget {
  const _FavoriteImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.photo,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _DefaultCoverPlaceholder extends StatelessWidget {
  const _DefaultCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.45),
            colorScheme.primaryContainer.withValues(alpha: 0.35),
          ],
        ),
      ),
    );
  }
}

Widget _buildPlaceholderScroll({
  required BuildContext context,
  required Widget child,
}) {
  final size = MediaQuery.of(context).size;
  return ListView(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
    children: [
      SizedBox(
        height: size.height * 0.25,
        child: Center(child: child),
      ),
    ],
  );
}

final _profileProvider =
    AsyncNotifierProvider<_ProfileNotifier, User>(_ProfileNotifier.new);

final _activitiesProvider = AsyncNotifierProvider<_ActivitiesNotifier,
    List<ActivityItem>>(_ActivitiesNotifier.new);

final _favoritesProvider = AsyncNotifierProvider<_FavoritesNotifier,
    List<Event>>(_FavoritesNotifier.new);

class _ProfileNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() => _fetch();

  Future<User> _fetch() async {
    final api = ref.read(apiServiceProvider);
    final dto = await api.getAuthenticatedUserDetail();
    final displayName = _normalizeText(dto.displayName);
    final name = displayName ?? _nameFromEmail(dto.email);
    return User(
      uid: dto.id,
      name: name,
      bio: _normalizeText(dto.bio),
      avatar: _normalizeUrl(dto.photoUrl),
      cover: _normalizeUrl(dto.coverUrl),
      followers: dto.followers ?? 0,
      following: dto.following ?? 0,
      likes: dto.likes ?? 0,
      followed: dto.isFollowed ?? false,
    );
  }
}

class _ActivitiesNotifier extends AsyncNotifier<List<ActivityItem>> {
  @override
  Future<List<ActivityItem>> build() async {
    final api = ref.read(apiServiceProvider);
    return api.getUserEvents();
  }
}

class _FavoritesNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    final api = ref.read(apiServiceProvider);
    return api.getUserFavoriteEvents();
  }
}

String _nameFromEmail(String email) {
  final trimmed = email.trim();
  final atIndex = trimmed.indexOf('@');
  if (atIndex > 0) {
    return trimmed.substring(0, atIndex);
  }
  return trimmed;
}

String? _normalizeText(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _normalizeUrl(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

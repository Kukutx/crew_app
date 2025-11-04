import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/moment/sheets/moment_post_comments_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/moment/widgets/moment_post_detail_screen.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/features/events/presentation/widgets/moment_post_card.dart';
import 'package:crew_app/features/events/presentation/pages/moment/sheets/create_content_options_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/trips/road_trip_editor_page.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';

import '../../../../../../app/state/app_overlay_provider.dart';
import '../../../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import '../state/map_overlay_sheet_provider.dart';

class MapExploreSheet extends ConsumerStatefulWidget {
  const MapExploreSheet({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<MapExploreSheet> createState() => _MapExploreSheetState();
}

class _MapExploreSheetState extends ConsumerState<MapExploreSheet> {
  int _tab = 0;
  String? _selectedFilter;

  static const _filters = ['附近', '最新', '热门', '关注'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filters.first;
  }

  static const List<MomentPost> _momentPosts = [
    MomentPost(
      author: '阿里',
      authorInitials: 'AL',
      timeLabel: '15分钟前',
      content: '周末准备在城北绿地举办一次自由野餐。大家可以带上自己的拿手菜和户外桌游，一起分享～',
      location: '城北城市绿地',
      tags: ['野餐', '城市漫游'],
      likes: 36,
      comments: 12,
      accentColor: Color(0xFF6750A4),
      momentType: MomentType.event,
      mediaAssets: [
        'assets/images/crew.png',
        'assets/images/crew.png',
        'assets/images/crew.png',
        'assets/images/crew.png',
      ],
      commentItems: [
        MomentComment(
          author: 'Lydia',
          message: '带上我最爱的野餐布和小蛋糕，一起享受日落吧～',
          timeLabel: '10分钟前',
        ),
        MomentComment(
          author: '橙子汽水',
          message: '天气不错的话我可以带飞盘，顺便拍点照片。',
          timeLabel: '刚刚',
        ),
      ],
    ),
    MomentPost(
      author: '阿黑',
      authorInitials: 'AL',
      timeLabel: '15分钟前',
      content: '周末准备在城北绿地举办一次自由野餐。大家可以带上自己的拿手菜和户外桌游，一起分享～',
      location: '城北城市绿地',
      tags: ['野餐', '城市漫游'],
      likes: 36,
      comments: 12,
      accentColor: Color(0xFF6750A4),
      momentType: MomentType.event,
      commentItems: [
        MomentComment(
          author: 'Lydia',
          message: '带上我最爱的野餐布和小蛋糕，一起享受日落吧～',
          timeLabel: '10分钟前',
        ),
        MomentComment(
          author: '橙子汽水',
          message: '天气不错的话我可以带飞盘，顺便拍点照片。',
          timeLabel: '刚刚',
        ),
      ],
    ),
    MomentPost(
      author: '米兰小巷',
      authorInitials: 'ML',
      timeLabel: '1小时前',
      content: '本周的 City Walk 想围绕老城区的咖啡小店，欢迎分享想去的店和故事。',
      location: '米兰大教堂附近',
      tags: ['咖啡', 'City Walk', '摄影'],
      likes: 52,
      comments: 18,
      accentColor: Color(0xFF4C6ED7),
      momentType: MomentType.instant,
      mediaAssets: [
        'assets/images/crew.png',
        'assets/images/crew.png',
        'assets/images/crew.png',
      ],
      commentItems: [
        MomentComment(
          author: '阿毛',
          message: '推荐一家藏在巷子里的手冲店，豆子超香！',
          timeLabel: '45分钟前',
        ),
        MomentComment(
          author: '蓝莓司康',
          message: '我可以带胶片机一起去取景～',
          timeLabel: '30分钟前',
        ),
      ],
    ),
    MomentPost(
      author: '夏栀',
      authorInitials: 'XZ',
      timeLabel: '昨天',
      content: '周五晚想找人一起在河畔夜跑，节奏轻松，跑完一起去喝椰子水。',
      location: '运河公园',
      tags: ['运动', '夜跑'],
      likes: 21,
      comments: 7,
      accentColor: Color(0xFF377D71),
      momentType: MomentType.instant,
      mediaAssets: ['assets/images/crew.png', 'assets/images/crew.png'],
      commentItems: [
        MomentComment(
          author: '晨跑小队',
          message: '夜跑完可以去河对岸那家椰子店，超级解暑。',
          timeLabel: '20小时前',
        ),
        MomentComment(
          author: '夏天的风',
          message: '我带上音响，跑完拉伸顺便听会儿歌。',
          timeLabel: '18小时前',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

    // 刷新列表
    ref.listen<AsyncValue<List<Event>>>(eventsProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = _errorMessage(error);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          });
        },
      );
    });

    Widget buildInvitesContent() {
      return eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _CenteredMessage(text: loc.no_events);
          }

          return AppMasonryGrid(
            padding: const EdgeInsets.only(bottom: 16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: events.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) => EventGridCard(
              event: events[i],
              heroTag: 'event_$i',
              onShowOnMap: (event) {
                ref.read(mapOverlaySheetProvider.notifier).state =
                    MapOverlaySheetType.none;
                ref.read(appOverlayIndexProvider.notifier).state = 0;
                ref.read(mapFocusEventProvider.notifier).state = event;
              },
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => _CenteredMessage(text: _errorMessage(error)),
      );
    }

    final scrollable = CustomScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          sliver: SliverToBoxAdapter(
            child: ToggleTabBar(
              selectedIndex: _tab,
              firstLabel: loc.events_tab_invites,
              secondLabel: loc.events_tab_moments,
              firstIcon: Icons.campaign,
              secondIcon: Icons.public,
              onChanged: (value) => setState(() => _tab = value),
              leadingBuilder: (context, _) {
                final theme = Theme.of(context);
                final buttonColor = theme.colorScheme.surfaceContainerHighest;

                return PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                  itemBuilder: (context) => [
                    for (final filter in _filters)
                      PopupMenuItem<String>(
                        value: filter,
                        child: Text(
                          filter,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: buttonColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedFilter ?? _filters.first,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                );
              },
              trailingBuilder: (context, selectedIndex) {
                final theme = Theme.of(context);
                final isInvitesTab = selectedIndex == 0;
                final onPressed = isInvitesTab
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (routeContext) => RoadTripEditorPage(
                              onClose: () => Navigator.of(routeContext).pop(),
                            ),
                          ),
                        );
                      }
                    : () => showCreateContentOptionsSheet(context);
                return Material(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onPressed,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.add, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _tab == 0
                  ? KeyedSubtree(
                      key: const ValueKey('invites'),
                      child: buildInvitesContent(),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('moment'),
                      child: _MapEventsMomentFeed(posts: _momentPosts),
                    ),
            ),
          ),
        ),
      ],
    );

    final effectiveContent = _tab == 0
        ? RefreshIndicator(
            onRefresh: () async =>
                await ref.refresh(eventsProvider.future),
            child: scrollable,
          )
        : scrollable;

    return SafeArea(
      top: false,
      bottom: true,
      child: effectiveContent,
    );
  }
}

class _MapEventsMomentFeed extends StatelessWidget {
  final List<MomentPost> posts;

  const _MapEventsMomentFeed({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      itemBuilder: (context, index) {
        final post = posts[index];
        return MomentPostCard(
          post: post,
          onMediaTap: () => Navigator.of(
            context,
          ).push(MomentPostDetailScreen.route(post: post)),
          onCommentTap: () => showMomentPostCommentsSheet(context, post),
          onAuthorTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const UserProfilePage())),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemCount: posts.length,
    );
  }
}

String _errorMessage(Object error) {
  if (error is ApiException) {
    return error.message.isNotEmpty ? error.message : error.toString();
  }
  final msg = error.toString();
  return msg.isEmpty ? 'Unknown error' : msg;
}

class _CenteredMessage extends StatelessWidget {
  final String text;

  const _CenteredMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}

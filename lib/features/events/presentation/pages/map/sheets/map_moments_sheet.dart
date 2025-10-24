import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/plaza/sheets/plaza_post_comments_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/plaza/widgets/plaza_post_detail_screen.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/features/events/presentation/widgets/plaza_post_card.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';

import '../../../../../../app/state/app_overlay_provider.dart';
import '../../../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

class MapMomentsSheet extends ConsumerStatefulWidget {
  const MapMomentsSheet({super.key});

  @override
  ConsumerState<MapMomentsSheet> createState() => _MapEventsExploreSheetState();
}

class _MapEventsExploreSheetState extends ConsumerState<MapMomentsSheet> {
  int _tab = 0;
  String? _selectedCountry;

  static const _countries = ['附近', '中国', '日本', '美国', '英国', '法国', '德国'];
  static const _defaultCountry = _countries.first;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _defaultCountry;
  }

  static const List<PlazaPost> _plazaPosts = [
    PlazaPost(
      author: '阿里',
      authorInitials: 'AL',
      timeLabel: '15分钟前',
      content: '周末准备在城北绿地举办一次自由野餐。大家可以带上自己的拿手菜和户外桌游，一起分享～',
      location: '城北城市绿地',
      tags: ['野餐', '城市漫游'],
      likes: 36,
      comments: 12,
      accentColor: Color(0xFF6750A4),
      momentType: PlazaMomentType.event,
      previewLabel: '日落草坪局',
      mediaAssets: [
        'assets/images/crew.png',
        'assets/images/crew.png',
        'assets/images/crew.png',
        'assets/images/crew.png',
      ],
      commentItems: [
        PlazaComment(
          author: 'Lydia',
          message: '带上我最爱的野餐布和小蛋糕，一起享受日落吧～',
          timeLabel: '10分钟前',
        ),
        PlazaComment(
          author: '橙子汽水',
          message: '天气不错的话我可以带飞盘，顺便拍点照片。',
          timeLabel: '刚刚',
        ),
      ],
    ),
    PlazaPost(
      author: '米兰小巷',
      authorInitials: 'ML',
      timeLabel: '1小时前',
      content: '本周的 City Walk 想围绕老城区的咖啡小店，欢迎分享想去的店和故事。',
      location: '米兰大教堂附近',
      tags: ['咖啡', 'City Walk', '摄影'],
      likes: 52,
      comments: 18,
      accentColor: Color(0xFF4C6ED7),
      momentType: PlazaMomentType.instant,
      previewLabel: '街角手冲香',
      mediaAssets: [
        'assets/images/crew.png',
        'assets/images/crew.png',
        'assets/images/crew.png',
      ],
      commentItems: [
        PlazaComment(
          author: '阿毛',
          message: '推荐一家藏在巷子里的手冲店，豆子超香！',
          timeLabel: '45分钟前',
        ),
        PlazaComment(
          author: '蓝莓司康',
          message: '我可以带胶片机一起去取景～',
          timeLabel: '30分钟前',
        ),
      ],
    ),
    PlazaPost(
      author: '夏栀',
      authorInitials: 'XZ',
      timeLabel: '昨天',
      content: '周五晚想找人一起在河畔夜跑，节奏轻松，跑完一起去喝椰子水。',
      location: '运河公园',
      tags: ['运动', '夜跑'],
      likes: 21,
      comments: 7,
      accentColor: Color(0xFF377D71),
      momentType: PlazaMomentType.instant,
      previewLabel: '河畔清风局',
      mediaAssets: ['assets/images/crew.png', 'assets/images/crew.png'],
      commentItems: [
        PlazaComment(
          author: '晨跑小队',
          message: '夜跑完可以去河对岸那家椰子店，超级解暑。',
          timeLabel: '20小时前',
        ),
        PlazaComment(
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

    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
              child: Row(
                children: [
                  Text(loc.events_title, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ToggleTabBar(
                selectedIndex: _tab,
                firstLabel: loc.events_tab_invites,
                secondLabel: loc.events_tab_moments,
                firstIcon: Icons.campaign,
                secondIcon: Icons.public,
                onChanged: (value) => setState(() => _tab = value),
                leadingBuilder: (context, selectedIndex) {
                  if (selectedIndex != 1) return null;

                  final theme = Theme.of(context);
                  final buttonColor = theme.colorScheme.surfaceContainerHighest;

                  final selectedCountry = _selectedCountry ?? _defaultCountry;

                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                          itemBuilder: (context) => [
                            for (final country in _countries)
                              PopupMenuItem<String>(
                                value: country,
                                child: Text(country),
                              ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(selectedCountry),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                        if (selectedCountry != _defaultCountry) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedCountry = _defaultCountry;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
                trailingBuilder: (context, selectedIndex) {
                  if (selectedIndex != 1) return null;

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => showCreateMomentSheet(context),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _tab == 0
                    ? KeyedSubtree(
                        key: const ValueKey('invites'),
                        child: RefreshIndicator(
                          onRefresh: () async =>
                              await ref.refresh(eventsProvider.future),
                          child: eventsAsync.when(
                            data: (events) {
                              if (events.isEmpty) {
                                return _CenteredScrollable(
                                  child: Text(loc.no_events),
                                );
                              }

                              return AppMasonryGrid(
                                padding: const EdgeInsets.all(8),
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                itemCount: events.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, i) => EventGridCard(
                                  event: events[i],
                                  heroTag: 'event_$i',
                                  onShowOnMap: (event) {
                                    Navigator.of(context).maybePop();
                                    ref
                                            .read(
                                              appOverlayIndexProvider.notifier,
                                            )
                                            .state =
                                        1;
                                    ref
                                            .read(
                                              mapFocusEventProvider.notifier,
                                            )
                                            .state =
                                        event;
                                  },
                                ),
                              );
                            },
                            loading: () => const _CenteredScrollable(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, _) => _CenteredScrollable(
                              child: Text(loc.load_failed),
                            ),
                          ),
                        ),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('plaza'),
                        child: _MapEventsPlazaFeed(posts: _plazaPosts),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapEventsPlazaFeed extends StatelessWidget {
  final List<PlazaPost> posts;

  const _MapEventsPlazaFeed({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PlazaPostCard(
          post: post,
          onMediaTap: () => Navigator.of(
            context,
          ).push(PlazaPostDetailScreen.route(post: post)),
          onCommentTap: () => showPlazaPostCommentsSheet(context, post),
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

class _CenteredScrollable extends StatelessWidget {
  final Widget child;

  const _CenteredScrollable({required this.child});

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

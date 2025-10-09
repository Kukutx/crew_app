import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';

import '../../../../../app/state/app_overlay_provider.dart';
import '../../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

class MapEventsListSheet extends ConsumerStatefulWidget {
  const MapEventsListSheet({super.key});

  @override
  ConsumerState<MapEventsListSheet> createState() => _MapEventsListSheetState();
}

class _MapEventsListSheetState extends ConsumerState<MapEventsListSheet> {
  int _tab = 0;

  static const List<_MapEventsPlazaPost> _plazaPosts = [
    _MapEventsPlazaPost(
      author: '阿里',
      authorInitials: 'AL',
      timeLabel: '15分钟前',
      content:
          '周末准备在城北绿地举办一次自由野餐。大家可以带上自己的拿手菜和户外桌游，一起分享～',
      location: '城北城市绿地',
      tags: ['野餐', '城市漫游'],
      likes: 36,
      comments: 12,
      accentColor: Color(0xFF6750A4),
      previewLabel: '日落草坪局',
    ),
    _MapEventsPlazaPost(
      author: '米兰小巷',
      authorInitials: 'ML',
      timeLabel: '1小时前',
      content: '本周的 City Walk 想围绕老城区的咖啡小店，欢迎分享想去的店和故事。',
      location: '米兰大教堂附近',
      tags: ['咖啡', 'City Walk', '摄影'],
      likes: 52,
      comments: 18,
      accentColor: Color(0xFF4C6ED7),
      previewLabel: '街角手冲香',
    ),
    _MapEventsPlazaPost(
      author: '夏栀',
      authorInitials: 'XZ',
      timeLabel: '昨天',
      content: '周五晚想找人一起在河畔夜跑，节奏轻松，跑完一起去喝椰子水。',
      location: '运河公园',
      tags: ['运动', '夜跑'],
      likes: 21,
      comments: 7,
      accentColor: Color(0xFF377D71),
      previewLabel: '河畔清风局',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

    // 刷新列表
    ref.listen<AsyncValue<List<Event>>>(eventsProvider, (prev, next) {
      next.whenOrNull(error: (error, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final msg = _errorMessage(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        });
      });
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
                  Text(
                    loc.events_title,
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
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ToggleTabBar(
                selectedIndex: _tab,
                firstLabel: loc.events_tab_invites,
                secondLabel: loc.events_tab_plaza,
                firstIcon: Icons.campaign,
                secondIcon: Icons.public,
                onChanged: (value) => setState(() => _tab = value),
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
                                    child: Text(loc.no_events));
                              }

                              return AppMasonryGrid(
                                padding: const EdgeInsets.all(8),
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                itemCount: events.length,
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, i) => EventGridCard(
                                  event: events[i],
                                  heroTag: 'event_$i',
                                  onShowOnMap: (event) {
                                    Navigator.of(context).maybePop();
                                    ref
                                        .read(appOverlayIndexProvider.notifier)
                                        .state = 1;
                                    ref
                                            .read(
                                                mapFocusEventProvider.notifier)
                                            .state =
                                        event;
                                  },
                                ),
                              );
                            },
                            loading: () => const _CenteredScrollable(
                                child: CircularProgressIndicator()),
                            error: (_, _) =>
                                _CenteredScrollable(child: Text(loc.load_failed)),
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
  final List<_MapEventsPlazaPost> posts;

  const _MapEventsPlazaFeed({required this.posts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(
        parent: const BouncingScrollPhysics(),
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: post.accentColor.withOpacity(0.15),
                      child: Text(
                        post.authorInitials,
                        style: TextStyle(
                          color: post.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post.timeLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.more_horiz,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.content,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.5),
                ),
                if (post.previewLabel != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 148,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            post.accentColor.withOpacity(0.85),
                            post.accentColor.withOpacity(0.55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        post.previewLabel!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: post.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#$tag',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 18, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        post.location,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MapEventsPlazaAction(
                      icon: Icons.favorite_border,
                      label: post.likes.toString(),
                    ),
                    const SizedBox(width: 16),
                    _MapEventsPlazaAction(
                      icon: Icons.chat_bubble_outline,
                      label: post.comments.toString(),
                    ),
                    const Spacer(),
                    _MapEventsPlazaAction(
                      icon: Icons.share_outlined,
                      label: '分享',
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: posts.length,
    );
  }
}

class _MapEventsPlazaAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dense;

  const _MapEventsPlazaAction({
    required this.icon,
    required this.label,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: dense ? FontWeight.w500 : FontWeight.w600,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _MapEventsPlazaPost {
  final String author;
  final String authorInitials;
  final String timeLabel;
  final String content;
  final String location;
  final List<String> tags;
  final int likes;
  final int comments;
  final Color accentColor;
  final String? previewLabel;

  const _MapEventsPlazaPost({
    required this.author,
    required this.authorInitials,
    required this.timeLabel,
    required this.content,
    required this.location,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.accentColor,
    this.previewLabel,
  });
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


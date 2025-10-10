import 'package:crew_app/features/events/presentation/widgets/plaza_post_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventPlazaCard extends StatelessWidget {
  final AppLocalizations loc;

  const EventPlazaCard({
    super.key,
    required this.loc,
  });

  static const List<PlazaPost> _posts = [
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
      previewLabel: '日落草坪局',
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
      previewLabel: '街角手冲香',
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
      previewLabel: '河畔清风局',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Text(
                loc.events_tab_plaza,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
        for (var i = 0; i < _posts.length; i++)
          PlazaPostCard(
            post: _posts[i],
            margin: EdgeInsets.fromLTRB(16, i == 0 ? 0 : 12, 16, 0),
          ),
      ],
    );
  }
}

import 'package:crew_app/features/events/presentation/pages/plaza/sheets/plaza_post_comments_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/plaza/widgets/plaza_post_detail_screen.dart';
import 'package:crew_app/features/events/presentation/widgets/plaza_post_card.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
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
      momentType: PlazaMomentType.event,
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
      author: '阿黑',
      authorInitials: 'AL',
      timeLabel: '15分钟前',
      content: '周末准备在城北绿地举办一次自由野餐。大家可以带上自己的拿手菜和户外桌游，一起分享～',
      location: '城北城市绿地',
      tags: ['野餐', '城市漫游'],
      likes: 36,
      comments: 12,
      accentColor: Color(0xFF6750A4),
      momentType: PlazaMomentType.event,
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
      momentType: PlazaMomentType.event,
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
      momentType: PlazaMomentType.event,
      mediaAssets: [
        'assets/images/crew.png',
        'assets/images/crew.png',
      ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _posts.length; i++)
          PlazaPostCard(
            post: _posts[i],
            margin: EdgeInsets.fromLTRB(16, i == 0 ? 0 : 12, 16, 0),
            onMediaTap: () => _openPostDetail(context, _posts[i]),
            onCommentTap: () => showPlazaPostCommentsSheet(context, _posts[i]),
            onAuthorTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            ),
          ),
      ],
    );
  }
}

void _openPostDetail(BuildContext context, PlazaPost post) {
  Navigator.of(context).push(PlazaPostDetailScreen.route(post: post));
}

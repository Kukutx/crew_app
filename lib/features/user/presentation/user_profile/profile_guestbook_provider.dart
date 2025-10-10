import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileMessage {
  const ProfileMessage({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.tags = const [],
    this.location,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final List<String> tags;
  final String? location;
  final int likes;
  final int comments;
  final int shares;
}

class ProfileGuestbookNotifier extends StateNotifier<List<ProfileMessage>> {
  ProfileGuestbookNotifier()
      : super(
          const [
            ProfileMessage(
              id: 'm1',
              authorName: 'Crew 小助手',
              content: '本周的 City Walk 想围绕老城的咖啡小店，欢迎分享想去的店和故事。',
              timestamp: DateTime(2024, 5, 21, 18, 30),
              tags: ['City Walk', '咖啡'],
              location: '江南老城区',
              likes: 52,
              comments: 18,
              shares: 3,
            ),
            ProfileMessage(
              id: 'm2',
              authorName: 'Skywalker',
              content: '周五晚想找人一起在河畔夜跑，节奏轻松，跑完一起去喝椰子水。',
              timestamp: DateTime(2024, 5, 20, 20, 15),
              tags: ['夜跑'],
              location: '滨江公园',
              likes: 36,
              comments: 12,
              shares: 1,
            ),
          ],
        );

  void addMessage(String authorName, String content) {
    final message = ProfileMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorName: authorName,
      content: content,
      timestamp: DateTime.now(),
      tags: const [],
      location: null,
      likes: 0,
      comments: 0,
      shares: 0,
    );

    state = [message, ...state];
  }
}

final profileGuestbookProvider =
    StateNotifierProvider<ProfileGuestbookNotifier, List<ProfileMessage>>(
  (ref) => ProfileGuestbookNotifier(),
);

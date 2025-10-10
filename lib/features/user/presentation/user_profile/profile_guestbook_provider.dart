import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileMessage {
  const ProfileMessage({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;
}

class ProfileGuestbookNotifier extends StateNotifier<List<ProfileMessage>> {
  ProfileGuestbookNotifier()
      : super(
          const [
            ProfileMessage(
              id: 'm1',
              authorName: 'Crew 小助手',
              content: '欢迎来到 Luna 的主页，记得留下你的足迹哦！',
              timestamp: DateTime(2024, 1, 12, 9, 30),
            ),
            ProfileMessage(
              id: 'm2',
              authorName: 'Skywalker',
              content: '上次的徒步活动太棒了，期待下一次相聚～',
              timestamp: DateTime(2024, 3, 2, 18, 45),
            ),
          ],
        );

  void addMessage(String authorName, String content) {
    final message = ProfileMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorName: authorName,
      content: content,
      timestamp: DateTime.now(),
    );

    state = [message, ...state];
  }
}

final profileGuestbookProvider =
    StateNotifierProvider<ProfileGuestbookNotifier, List<ProfileMessage>>(
  (ref) => ProfileGuestbookNotifier(),
);

import 'package:flutter_riverpod/legacy.dart';

class ProfileMessage {
  const ProfileMessage({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
}

class ProfileGuestbookNotifier extends StateNotifier<List<ProfileMessage>> {
  ProfileGuestbookNotifier()
      : super(
          [
            ProfileMessage(
              id: 'm1',
              authorName: 'Crew 小助手',
              content: '麻了',
              timestamp: DateTime(2024, 5, 21, 18, 30),
              likes: 52,
              comments: 18,
            ),
            ProfileMessage(
              id: 'm2',
              authorName: 'Skywalker',
              content: '听说了吗, 隔壁老王要生了',
              timestamp: DateTime(2024, 5, 20, 20, 15),
              likes: 36,
              comments: 12,
            ),
          ],
        );

  void addMessage(String authorName, String content) {
    final message = ProfileMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorName: authorName,
      content: content,
      timestamp: DateTime.now(),
      likes: 0,
      comments: 0,
    );

    state = [message, ...state];
  }

  void updateMessage(String id, String content) {
    state = [
      for (final msg in state)
        if (msg.id == id)
          ProfileMessage(
            id: msg.id,
            authorName: msg.authorName,
            content: content,
            timestamp: msg.timestamp,
            likes: msg.likes,
            comments: msg.comments,
          )
        else
          msg,
    ];
  }

  void deleteMessage(String id) {
    state = state.where((msg) => msg.id != id).toList();
  }
}

final profileGuestbookProvider =
    StateNotifierProvider<ProfileGuestbookNotifier, List<ProfileMessage>>(
  (ref) => ProfileGuestbookNotifier(),
);


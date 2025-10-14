import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/features/user/data/user.dart';

final userProfileProvider = AutoDisposeAsyncNotifierProvider<
    UserProfileController, User>(UserProfileController.new);

class UserProfileController extends AutoDisposeAsyncNotifier<User> {
  static const _initialUser = User(
    uid: 'u_001',
    name: 'Luna',
    bio: '爱户外、爱分享 | Crew 资深爱好者',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    cover: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
    followers: 200,
    following: 5,
    events: 32,
    followed: false,
    tags: ['露营玩家', '摄影控', '旅拍达人'],
  );

  @override
  FutureOr<User> build() async {
    return _loadProfile();
  }

  Future<void> toggleFollow() async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final optimistic = current.copyWith(
      followed: !current.followed,
      followers:
          current.followed ? current.followers - 1 : current.followers + 1,
    );

    state = AsyncValue.data(optimistic);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadProfile);
  }

  Future<User> _loadProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _initialUser;
  }
}

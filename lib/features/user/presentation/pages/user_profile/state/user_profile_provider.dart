import 'package:crew_app/features/user/data/user.dart';
import 'package:flutter_riverpod/legacy.dart';

final userProfileProvider = StateProvider<User>((ref) {
  return User(
    uid: 'u_001',
    name: 'Luna',
    bio: '爱户外、爱分享 | Crew 资深爱好者',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    cover: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
    followers: 200,
    following: 5,
    events: 32,
    followed: false,
    gender: Gender.female,
    tags: ['露营玩家', '摄影控', '旅拍达人'],
    countryCode: 'CN',
  );
});

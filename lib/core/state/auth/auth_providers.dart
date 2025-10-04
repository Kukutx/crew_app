import 'package:crew_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

/// 登录态（只读流）：UI 用 `ref.watch(authStateProvider)` 拿到 `AsyncValue<User?>`
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// 当前用户快照（同步）：大多数展示场景更轻量
final currentUserProvider = Provider<User?>((ref) {
  // 监听 `authStateProvider` 确保在登录状态变化时重新读取当前用户，
  // 避免使用缓存的旧用户信息导致 UI 不更新。
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

/// 退出登录动作
final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(authRepositoryProvider).signOut();
});

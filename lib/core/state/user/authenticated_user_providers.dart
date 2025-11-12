import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/providers/api_provider_helper.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authenticatedUserProvider =
    StateNotifierProvider.autoDispose<AuthenticatedUserNotifier,
        AsyncValue<AuthenticatedUserDto?>>((ref) {
  return AuthenticatedUserNotifier(ref);
});

class AuthenticatedUserNotifier
    extends StateNotifier<AsyncValue<AuthenticatedUserDto?>> {
  AuthenticatedUserNotifier(this._ref)
      : super(const AsyncValue<AuthenticatedUserDto?>.data(null)) {
    _listenToAuthChanges();
    Future.microtask(_initialize);
  }

  final Ref _ref;

  /// 监听认证状态变化
  void _listenToAuthChanges() {
    _ref.listen<User?>(currentUserProvider, (previous, next) {
      if (next == null) {
        state = const AsyncValue<AuthenticatedUserDto?>.data(null);
        return;
      }

      if (previous == null || previous.uid != next.uid) {
        refreshProfile();
      }
    });
  }

  Future<void> _initialize() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue<AuthenticatedUserDto?>.loading();
    state = await AsyncValue.guard(_loadProfile);
  }

  /// 刷新用户资料
  Future<void> refreshProfile() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<AuthenticatedUserDto?>.data(null);
      return;
    }

    state = const AsyncValue<AuthenticatedUserDto?>.loading();
    state = await AsyncValue.guard(_loadProfile);
  }

  Future<AuthenticatedUserDto?> _loadProfile() async {
    try {
      return await ApiProviderHelper.callApi(
        _ref,
        (api) => api.getAuthenticatedUserDetail(),
      );
    } on ApiException catch (error) {
      // 对于这些状态码，返回 null 而不是抛出异常
      final status = error.statusCode;
      if (status == 401 || status == 403 || status == 404 || status == 204) {
        return null;
      }
      rethrow;
    }
  }
}


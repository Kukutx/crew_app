import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _initialize();
  }

  final Ref _ref;

  void _listenToAuthChanges() {
    _ref.listen<User?>(currentUserProvider, (previous, next) {
      final previousUser = previous;
      final currentUser = next;

      if (currentUser == null) {
        state = const AsyncValue<AuthenticatedUserDto?>.data(null);
        return;
      }

      if (previousUser == null || previousUser.uid != currentUser.uid) {
        refreshProfile();
      }
    });
  }

  Future<void> _initialize() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<AuthenticatedUserDto?>.data(null);
      return;
    }

    state = const AsyncValue<AuthenticatedUserDto?>.loading();
    state = await AsyncValue.guard(_loadProfile);
  }

  Future<AuthenticatedUserDto?> refreshProfile() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<AuthenticatedUserDto?>.data(null);
      return null;
    }

    state = const AsyncValue<AuthenticatedUserDto?>.loading();
    state = await AsyncValue.guard(_loadProfile);
    return state.asData?.value;
  }

  Future<AuthenticatedUserDto?> _loadProfile() async {
    final api = _ref.read(apiServiceProvider);

    try {
      return await api.getAuthenticatedUserDetail();
    } on ApiException catch (error) {
      final status = error.statusCode;
      if (status == null) {
        rethrow;
      }

      if (status == 401 || status == 403 || status == 404 || status == 204) {
        return null;
      }

      rethrow;
    }
  }
}

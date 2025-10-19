import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/auth/ensure_user_service.dart';
import 'package:crew_app/features/models/user/user_profile_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authenticatedUserProvider =
    StateNotifierProvider.autoDispose<AuthenticatedUserNotifier,
        AsyncValue<UserProfileDto?>>((ref) {
  return AuthenticatedUserNotifier(ref);
});

class AuthenticatedUserNotifier
    extends StateNotifier<AsyncValue<UserProfileDto?>> {
  AuthenticatedUserNotifier(this._ref)
      : super(const AsyncValue<UserProfileDto?>.data(null)) {
    _listenToAuthChanges();
  }

  final Ref _ref;

  void _listenToAuthChanges() {
    _ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final previousUser = previous?.valueOrNull;
      final currentUser = next.valueOrNull;

      if (currentUser == null) {
        state = const AsyncValue<UserProfileDto?>.data(null);
        _ref.read(ensureUserServiceProvider).reset();
        return;
      }

      if (previousUser == null || previousUser.uid != currentUser.uid) {
        state = const AsyncValue<UserProfileDto?>.loading();
        return;
      }
    });
  }

  Future<UserProfileDto?> refreshProfile({bool forceEnsure = false}) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<UserProfileDto?>.data(null);
      return null;
    }

    state = const AsyncValue<UserProfileDto?>.loading();
    final nextState = await AsyncValue.guard(
      () => _loadProfile(forceEnsure: forceEnsure),
    );
    if (!mounted) return null;
    state = nextState;
    return state.asData?.value;
  }

  Future<UserProfileDto?> _loadProfile({bool forceEnsure = false}) async {
    final firebaseUser = _ref.read(currentUserProvider);
    if (firebaseUser == null) {
      return null;
    }

    final ensureService = _ref.read(ensureUserServiceProvider);
    try {
      return await ensureService.ensureUser(force: forceEnsure);
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

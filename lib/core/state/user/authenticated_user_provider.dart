import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/models/user/ensure_user_request.dart';
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
    _initialize();
  }

  final Ref _ref;

  void _listenToAuthChanges() {
    _ref.listen<User?>(currentUserProvider, (previous, next) {
      final previousUser = previous;
      final currentUser = next;

      if (currentUser == null) {
        state = const AsyncValue<UserProfileDto?>.data(null);
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
      state = const AsyncValue<UserProfileDto?>.data(null);
      return;
    }

    state = const AsyncValue<UserProfileDto?>.loading();
    final nextState = await AsyncValue.guard(_loadProfile);
    if (!mounted) return;
    state = nextState;
  }

  Future<UserProfileDto?> refreshProfile() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<UserProfileDto?>.data(null);
      return null;
    }

    state = const AsyncValue<UserProfileDto?>.loading();
    final nextState = await AsyncValue.guard(_loadProfile);
    if (!mounted) return null;
    state = nextState;
    return state.asData?.value;
  }

  Future<UserProfileDto?> _loadProfile() async {
    final api = _ref.read(apiServiceProvider);
    final firebaseUser = _ref.read(currentUserProvider);
    if (firebaseUser == null) {
      return null;
    }

    final displayName = firebaseUser.displayName?.trim();
    final email = firebaseUser.email?.trim();
    final request = EnsureUserRequest(
      firebaseUid: firebaseUser.uid,
      displayName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : (email != null && email.isNotEmpty
              ? email
              : 'Crew Member'),
      email: email ?? '${firebaseUser.uid}@firebase.local',
      role: 'User',
      avatarUrl: firebaseUser.photoURL,
      bio: null,
      tags: null,
    );

    try {
      return await api.ensureUser(request);
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

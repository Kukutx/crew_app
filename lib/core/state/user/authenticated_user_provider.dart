import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticatedUserProvider = AutoDisposeAsyncNotifierProvider<
    AuthenticatedUserNotifier, AuthenticatedUserDto?>(
  AuthenticatedUserNotifier.new,
);

class AuthenticatedUserNotifier
    extends AutoDisposeAsyncNotifier<AuthenticatedUserDto?> {
  @override
  Future<AuthenticatedUserDto?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return null;
    }

    return _loadProfile();
  }

  Future<AuthenticatedUserDto?> refreshProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncData(null);
      return null;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadProfile);
    return state.asData?.value;
  }

  Future<AuthenticatedUserDto?> _loadProfile() async {
    final api = ref.read(apiServiceProvider);

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

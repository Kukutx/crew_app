import 'dart:async';

import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/auth/ensure_user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ensureUserAuthStateListenerProvider = Provider<void>((ref) {
  User? previousUser;
  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    final currentUser = next.valueOrNull;
    if (currentUser == null) {
      previousUser = null;
      ref.read(ensureUserServiceProvider).reset();
      return;
    }

    if (previousUser != null && previousUser!.uid == currentUser.uid) {
      return;
    }

    previousUser = currentUser;

    final shouldForce = previous?.valueOrNull == null ||
        previous?.valueOrNull?.uid != currentUser.uid;

    unawaited(
      ref
          .read(authenticatedUserProvider.notifier)
          .refreshProfile(forceEnsure: shouldForce),
    );
  }, fireImmediately: true);
});

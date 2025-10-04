import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_service.dart';
import '../../network/auth/auth_service.dart';
import '../../network/auth/firebase_auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    authService: ref.watch(authServiceProvider),
  );
});

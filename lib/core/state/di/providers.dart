import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_service.dart';

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(firebaseAuth: ref.watch(firebaseAuthProvider));
});

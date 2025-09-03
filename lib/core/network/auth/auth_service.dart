import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Stream<User?> authStateChanges();
  User? get currentUser;

  Future<void> signOut();
  Future<String?> getIdToken({bool forceRefresh = false});

  // 可按需扩展：后台受保护 API 需要的 header,提供一个已实现的默认方法
  Future<Map<String, String>> authHeader() async {
    final token = await getIdToken();
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }
}

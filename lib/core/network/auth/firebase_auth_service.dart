import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

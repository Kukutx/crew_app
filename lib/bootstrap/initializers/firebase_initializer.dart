import 'package:firebase_core/firebase_core.dart';

import 'package:crew_app/core/config/firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer();

  Future<FirebaseApp> initialize() {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

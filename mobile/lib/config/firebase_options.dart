import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBjRYud7zhvZw2cxuwPOzJZjtpiIRx7Q0Y",
    authDomain: "app-qr-f5e62.firebaseapp.com",
    projectId: "app-qr-f5e62",
    storageBucket: "app-qr-f5e62.firebasestorage.app",
    messagingSenderId: "335566921346",
    appId: "1:335566921346:web:58bd79c446b60b35e19e9b",
    measurementId: "G-WR1M19MSNV",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBjRYud7zhvZw2cxuwPOzJZjtpiIRx7Q0Y",
    appId: "1:335566921346:android:58bd79c446b60b35e19e9b",
    messagingSenderId: "335566921346",
    projectId: "app-qr-f5e62",
    storageBucket: "app-qr-f5e62.firebasestorage.app",
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }
}

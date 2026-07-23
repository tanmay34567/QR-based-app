import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        // Production Firebase Web Configuration
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyBjRYud7zhvZw2cxuwPOzJZjtpiIRx7Q0Y",
            authDomain: "app-qr-f5e62.firebaseapp.com",
            projectId: "app-qr-f5e62",
            storageBucket: "app-qr-f5e62.firebasestorage.app",
            messagingSenderId: "335566921346",
            appId: "1:335566921346:web:58bd79c446b60b35e19e9b",
            measurementId: "G-WR1M19MSNV",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const QrDialerApp());
}

class QrDialerApp extends StatelessWidget {
  const QrDialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApiService(),
      child: MaterialApp(
        title: 'TEL QR Dialer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            primary: const Color(0xFF2563EB),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance;
      }
    } catch (e) {
      debugPrint('FirebaseAuth instance notice: $e');
    }
    return null;
  }

  FirebaseAuth? get auth => _auth;
  User? get currentUser => _auth?.currentUser;

  /// Trigger Firebase Phone Number OTP Verification
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String message) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    int? forceResendingToken,
  }) async {
    final firebaseAuth = _auth;

    if (firebaseAuth == null) {
      onError('Firebase Auth is not fully configured for this platform. You can click "Use Dev Mode" below to proceed.');
      return;
    }

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('Firebase Auto Verification Completed');
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Firebase Verification Failed: ${e.code} - ${e.message}');
          onError(e.message ?? 'Phone number verification failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('OTP Code Sent to $phoneNumber');
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Code Auto Retrieval Timeout: $verificationId');
        },
      );
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      onError('Failed to process phone verification: $e');
    }
  }

  /// Verify entered SMS code and obtain Firebase ID Token
  Future<String?> verifyOtpAndGetIdToken({
    required String verificationId,
    required String smsCode,
  }) async {
    final firebaseAuth = _auth;
    if (firebaseAuth == null) return null;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return null;
    }
  }

  /// Generate Dev / Mock ID Token when testing locally without active Firebase app
  String getDevTestToken(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return 'test_token_$cleanPhone';
  }
}

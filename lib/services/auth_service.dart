import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  // ── Step 1: Send OTP ────────────────────────────────────────────────────────
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(UserCredential)? onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: _resendToken,

      // Auto-retrieved on some Android devices (no user action needed)
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("[Auth] verificationCompleted fired — auto signing in");
        final result = await _auth.signInWithCredential(credential);
        onAutoVerified?.call(result);
      },

      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },

      codeSent: (String verificationId, int? resendToken) {
        print("[Auth] codeSent — verificationId: $verificationId");
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        print("[Auth] codeAutoRetrievalTimeout — verificationId: $verificationId");
        _verificationId = verificationId;
      },
    );
  }

  // ── Step 2: Verify OTP ──────────────────────────────────────────────────────
  Future<UserCredential> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw Exception('No verification ID found. Please request OTP first.');
    }
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  Future<void> signOut() => _auth.signOut();
}

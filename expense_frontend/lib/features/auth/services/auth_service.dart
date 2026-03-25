import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// SIGNUP
  Future<String?> signup(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();

      return "Verification email sent";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// LOGIN
  Future<String?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        return "Please verify your email first";
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// FORGOT PASSWORD
  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Reset link sent";
    } catch (e) {
      return "Error occurred";
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}

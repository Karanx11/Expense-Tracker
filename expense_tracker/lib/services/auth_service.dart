import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// SIGNUP
  Future<User?> signup(String email, String password) async {
    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await user.user!.sendEmailVerification();

    return user.user;
  }

  /// LOGIN
  Future<User?> login(String email, String password) async {
    UserCredential user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!user.user!.emailVerified) {
      throw Exception("Verify email first");
    }

    return user.user;
  }

  /// LOGOUT
  Future logout() async {
    await _auth.signOut();
  }

  /// RESET PASSWORD
  Future forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Stream<User?> get userStream => _auth.authStateChanges();

  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // login sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan saat login";
    }
  }


  static Future<String?> register(String name, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan";
    }
  }

  static Future<void> logout() async => await _auth.signOut();
}

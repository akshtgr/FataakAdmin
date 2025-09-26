import 'package:flutter/material.dart'; // Corrected import
import 'package:firebase_auth/firebase_auth.dart';

// Class definition is now correct because of the import
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners(); // This will now work correctly
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners(); // This will now work correctly
  }
}
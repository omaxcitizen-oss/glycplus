import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor
  AuthService(this._auth);

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password, bool rememberMe) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
      }
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Ensure the user object is not null
      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(username);
        // Create user document in Firestore and wait for it to complete
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
        });
        // Reload the user to get the updated display name
        await user.reload();
      }
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await _auth.signOut();
  }

  // Check if the user is remembered
  Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// Talks to Firebase Authentication and the users collection. No UI code here.
class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get userChanges => _auth.userChanges();

  Future<void> register(
      {required String name,
      required String email,
      required String password}) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      throw FirebaseAuthException(
          code: 'invalid-name', message: 'Name is required.');
    }
    if (cleanEmail.isEmpty) {
      throw FirebaseAuthException(
          code: 'invalid-email', message: 'Email is required.');
    }
    if (password.isEmpty) {
      throw FirebaseAuthException(
          code: 'invalid-password', message: 'Password is required.');
    }

    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
          email: cleanEmail, password: password);
    } on FirebaseAuthException {
      rethrow;
    }

    final user = cred.user;
    if (user == null) {
      throw StateError('User was not created.');
    }

    try {
      await user.updateDisplayName(cleanName);
      await _db.collection('users').doc(user.uid).set({
        'name': cleanName,
        'email': cleanEmail,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.sendEmailVerification();
    } catch (_) {
      await _rollbackRegistration(user);
      rethrow;
    }
  }

  Future<void> _rollbackRegistration(User user) async {
    try {
      await _db.collection('users').doc(user.uid).delete();
    } catch (_) {
      // Ignore cleanup errors; the original failure is still the important one.
    }

    try {
      await user.delete();
    } catch (_) {
      // Ignore cleanup errors; the original failure is still the important one.
    }
  }

  Future<void> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> logout() => _auth.signOut();

  Future<void> resendVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  /// Reloads the user and refreshes the ID token so Firestore rules see email_verified = true.
  Future<bool> refreshVerified() async {
    final u = _auth.currentUser;
    if (u == null) return false;
    await u.reload();
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<AppUser?> loadProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return AppUser.fromMap(uid, data);
  }
}

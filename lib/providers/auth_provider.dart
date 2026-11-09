import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Holds authentication state: who is signed in, their role, loading and errors.
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  StreamSubscription<User?>? _sub;

  User? _user;
  AppUser? _profile;
  bool _initializing = true;
  bool _busy = false;
  String? _error;

  AuthProvider() {
    if (Firebase.apps.isNotEmpty) {
      _sub = _service.userChanges.listen(_onUser);
    } else {
      _initializing = false;
      notifyListeners();
    }
  }

  User? get user => _user;
  AppUser? get profile => _profile;
  bool get initializing => _initializing;
  bool get busy => _busy;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isVerified => _user?.emailVerified ?? false;
  bool get isStaff => _profile?.isStaff ?? false;

  Future<void> _onUser(User? u) async {
    _user = u;
    if (u == null) {
      _profile = null;
    } else if (_profile?.uid != u.uid) {
      await _loadProfile(u);
    }
    _initializing = false;
    notifyListeners();
  }

  Future<void> _loadProfile(User u) async {
    try {
      _profile = await _service.loadProfile(u.uid);
    } catch (_) {
      _profile = null;
    }
    // The profile document may not exist yet right after registration.
    _profile ??= AppUser(
        uid: u.uid,
        name: u.displayName ?? '',
        email: u.email ?? '',
        role: 'student');
  }

  Future<bool> register(String name, String email, String password) => _run(
      () => _service.register(name: name, email: email, password: password));

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<void> logout() async {
    await _service.logout();
  }

  Future<bool> resendVerification() =>
      _run(() => _service.resendVerification());

  /// Called from the "I've verified" button.
  Future<bool> checkVerified() async {
    final ok = await _service.refreshVerified();
    _user = _service.currentUser;
    if (_user != null) await _loadProfile(_user!);
    notifyListeners();
    return ok;
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _message(e.code);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-name':
        return 'Please enter your full name.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-password':
        return 'Please enter a password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed ($code).';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

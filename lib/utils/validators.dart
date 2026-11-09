import 'constants.dart';

/// Form validators (pure functions, easy to unit test).
class Validators {
  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? aluEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final m = RegExp(r'^[^@\s]+@([^@\s]+)$').firstMatch(v.trim().toLowerCase());
    if (m == null) return 'Enter a valid email';
    if (!AppConstants.allowedDomains.contains(m.group(1))) {
      return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    }
    return null;
  }

  static String? password(String? v) =>
      (v == null || v.length < 8) ? 'Use at least 8 characters' : null;

  static String? minLength(String? v, int n, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    if (v.trim().length < n) return '$label must be at least $n characters';
    return null;
  }
}

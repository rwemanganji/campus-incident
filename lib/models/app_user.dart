/// A signed-in user's profile (stored in Firestore: users/{uid}).
class AppUser {
  final String uid, name, email, role;
  const AppUser(
      {required this.uid,
      required this.name,
      required this.email,
      required this.role});

  bool get isStaff => role == 'staff';

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        name: (m['name'] ?? '').toString().trim(),
        email: (m['email'] ?? '').toString().trim(),
        role: (m['role'] ?? 'student').toString().trim().isEmpty
            ? 'student'
            : (m['role'] ?? 'student').toString().trim(),
      );
}

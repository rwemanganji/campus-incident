import 'package:cloud_firestore/cloud_firestore.dart';

/// One entry in an incident's status history.
class StatusEntry {
  final String status, by;
  final DateTime at;
  const StatusEntry({required this.status, required this.at, required this.by});

  factory StatusEntry.fromMap(Map<String, dynamic> m) => StatusEntry(
        status: m['status'] as String,
        at: (m['at'] as Timestamp).toDate(),
        by: (m['by'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {'status': status, 'at': Timestamp.fromDate(at), 'by': by};
}

/// An incident report (Firestore: incidents/{id}).
class Incident {
  final String id, title, description, category, location, status, reporterId, reporterName;
  final bool anonymous;
  final String? photoUrl;
  final DateTime createdAt, updatedAt;
  final List<StatusEntry> history;

  const Incident({
    required this.id, required this.title, required this.description, required this.category,
    required this.location, required this.status, required this.reporterId, required this.reporterName,
    required this.anonymous, required this.photoUrl, required this.createdAt, required this.updatedAt,
    required this.history,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    // createdAt can be null for a moment while the server timestamp is pending.
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return Incident(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      location: (d['location'] ?? '') as String,
      status: (d['status'] ?? 'Submitted') as String,
      reporterId: (d['reporterId'] ?? '') as String,
      reporterName: (d['reporterName'] ?? '') as String,
      anonymous: (d['anonymous'] ?? false) as bool,
      photoUrl: d['photoUrl'] as String?,
      createdAt: ts(d['createdAt']),
      updatedAt: ts(d['updatedAt']),
      history: ((d['history'] ?? []) as List)
          .map((e) => StatusEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

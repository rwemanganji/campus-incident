import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/app_user.dart';
import '../models/incident.dart';

/// Firestore + Storage access for incident reports (create, read, update, delete).
class IncidentService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('incidents');

  /// READ: live stream of all incidents, newest first.
  Stream<List<Incident>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Incident.fromDoc).toList());

  /// CREATE: uploads the optional photo, then writes the document.
  Future<void> create({
    required AppUser reporter,
    required String title,
    required String description,
    required String category,
    required String location,
    required bool anonymous,
    File? photo,
  }) async {
    final ref = _col.doc();
    String? url;
    if (photo != null) {
      final file = _storage.ref('incidents/${reporter.uid}/${ref.id}.jpg');
      await file.putFile(photo, SettableMetadata(contentType: 'image/jpeg'));
      url = await file.getDownloadURL();
    }
    await ref.set({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': 'Submitted',
      'reporterId': reporter.uid,
      'reporterName': reporter.name,
      'anonymous': anonymous,
      'photoUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'history': [StatusEntry(status: 'Submitted', at: DateTime.now(), by: reporter.name).toMap()],
    });
  }

  /// UPDATE (staff only, enforced by Firestore rules): change status and log it in history.
  Future<void> updateStatus({required String id, required String status, required String staffName}) =>
      _col.doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'history': FieldValue.arrayUnion([StatusEntry(status: status, at: DateTime.now(), by: staffName).toMap()]),
      });

  /// DELETE: owner (while still Submitted) or staff. Photo removal is best-effort.
  Future<void> delete(Incident i) async {
    await _col.doc(i.id).delete();
    if (i.photoUrl != null) {
      try {
        await _storage.refFromURL(i.photoUrl!).delete();
      } catch (_) {}
    }
  }
}

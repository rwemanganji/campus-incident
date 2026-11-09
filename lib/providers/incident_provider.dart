import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import 'auth_provider.dart';

/// Holds incident data and UI filters. Screens read from here; they never touch Firestore directly.
class IncidentProvider extends ChangeNotifier {
  final AuthProvider _auth;
  final IncidentService _service = IncidentService();
  StreamSubscription<List<Incident>>? _sub;

  AppUser? _me;
  List<Incident> _all = [];
  bool loading = false;
  bool submitting = false;
  String? error;

  String query = '';
  String? statusFilter;
  String? categoryFilter;
  bool mineOnly = false;

  IncidentProvider(this._auth) {
    _auth.addListener(_onAuth);
    _onAuth();
  }

  // ---- Auth binding: start/stop the Firestore listener when the user changes.
  void _onAuth() {
    final me = (_auth.isLoggedIn && _auth.isVerified) ? _auth.profile : null;
    final changed = me?.uid != _me?.uid;
    _me = me;
    if (!changed) return;
    _sub?.cancel();
    _sub = null;
    _all = [];
    error = null;
    if (me == null) {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    _sub = _service.watchAll().listen((list) {
      _all = list;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (_) {
      loading = false;
      error = 'Could not load reports.';
      notifyListeners();
    });
  }

  // ---- Read helpers
  List<Incident> get all => _all;
  List<Incident> get mine => _all.where((i) => i.reporterId == _me?.uid).toList();
  List<Incident> get recent => _all.take(3).toList();

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Incident> get filtered {
    final q = query.trim().toLowerCase();
    return _all.where((i) {
      if (mineOnly && i.reporterId != _me?.uid) return false;
      if (statusFilter != null && i.status != statusFilter) return false;
      if (categoryFilter != null && i.category != categoryFilter) return false;
      if (q.isNotEmpty && !('${i.title} ${i.description} ${i.location}'.toLowerCase().contains(q))) return false;
      return true;
    }).toList();
  }

  int count(List<Incident> list, String status) => list.where((i) => i.status == status).length;

  // ---- Filters
  void setQuery(String v) { query = v; notifyListeners(); }
  void setStatus(String? v) { statusFilter = v; notifyListeners(); }
  void setCategory(String? v) { categoryFilter = v; notifyListeners(); }
  void toggleMine() { mineOnly = !mineOnly; notifyListeners(); }

  // ---- Actions
  Future<bool> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required bool anonymous,
    File? photo,
  }) {
    return _run(() => _service.create(
          reporter: _me!, title: title, description: description, category: category,
          location: location, anonymous: anonymous, photo: photo,
        ), 'Could not submit the report. Check your connection and try again.');
  }

  Future<bool> updateStatus(Incident i, String status) => _run(
        () => _service.updateStatus(id: i.id, status: status, staffName: _me?.name ?? 'Staff'),
        'Could not update the status.',
      );

  Future<bool> delete(Incident i) => _run(() => _service.delete(i), 'Could not delete the report.');

  Future<bool> _run(Future<void> Function() action, String failMessage) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      error = failMessage;
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuth);
    _sub?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/format.dart';
import '../widgets/status_chip.dart';

/// Shows one report (live from the provider), its status timeline, and role-based actions.
class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final inc = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final i = inc.byId(incidentId);

    if (i == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }

    final uid = auth.user?.uid;
    final isOwner = i.reporterId == uid;
    final canSeeIdentity = auth.isStaff || isOwner;
    final reporter = (i.anonymous && !canSeeIdentity) ? 'Anonymous' : i.reporterName;
    final canDelete = auth.isStaff || (isOwner && i.status == 'Submitted');

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          if (i.photoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  i.photoUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, child, p) =>
                      p == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(i.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            StatusChip(i.status),
          ]),
          const SizedBox(height: 12),
          _meta(Icons.category_outlined, i.category),
          _meta(Icons.location_on_outlined, i.location),
          _meta(Icons.schedule, 'Submitted ${fullDate(i.createdAt)}'),
          _meta(Icons.person_outline, 'Reported by $reporter'),
          const SizedBox(height: 20),
          const Text('Status Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...i.history.map((e) => _TimelineRow(e, last: e == i.history.last)),
          const SizedBox(height: 20),
          const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(i.description),
          if (auth.isStaff) ...[
            const SizedBox(height: 24),
            const Text('Update status (staff)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [for (final s in AppConstants.statuses) ButtonSegment(value: s, label: Text(s))],
              selected: {i.status},
              onSelectionChanged: inc.submitting ? null : (s) => _change(context, i, s.first),
            ),
          ],
          if (canDelete) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _confirmDelete(context, i),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete report'),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Expanded(child: Text(text))]),
      );

  Future<void> _change(BuildContext context, Incident i, String status) async {
    if (status == i.status) return;
    final p = context.read<IncidentProvider>();
    final ok = await p.updateStatus(i, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(ok ? 'Status updated to $status' : (p.error ?? 'Update failed'))));
  }

  Future<void> _confirmDelete(BuildContext context, Incident i) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    final p = context.read<IncidentProvider>();
    final ok = await p.delete(i);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(p.error ?? 'Delete failed')));
    }
  }
}

class _TimelineRow extends StatelessWidget {
  final StatusEntry entry;
  final bool last;
  const _TimelineRow(this.entry, {required this.last});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColor(entry.status);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 24,
          child: Column(children: [
            Icon(Icons.circle, size: 14, color: color),
            if (!last) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.status, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
              Text('${fullDate(entry.at)}${entry.by.isEmpty ? '' : ' \u2022 ${entry.by}'}',
                  style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ),
      ]),
    );
  }
}

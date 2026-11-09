import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../screens/incident_detail_screen.dart';
import '../utils/constants.dart';
import '../utils/format.dart';
import 'status_chip.dart';

/// Reusable list row for one incident. Tapping opens the detail screen.
class IncidentCard extends StatelessWidget {
  final Incident incident;
  const IncidentCard(this.incident, {super.key});

  @override
  Widget build(BuildContext context) {
    final i = incident;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: i.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: i.photoUrl != null
                    ? Image.network(i.photoUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(context))
                    : _placeholder(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('${i.category} \u2022 ${i.location}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.schedule, size: 14),
                  const SizedBox(width: 4),
                  Text(timeAgo(i.createdAt), style: const TextStyle(fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            StatusChip(i.status),
          ]),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(AppConstants.categoryIcon(incident.category)),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inc = context.watch<IncidentProvider>();
    final p = auth.profile;
    final name = p?.name ?? '';
    final mine = inc.mine;

    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(24), children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(p?.email ?? '', textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Center(child: Chip(label: Text(auth.isStaff ? 'Campus staff' : 'Student'))),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stat('Total', mine.length),
              _stat('In Progress', inc.count(mine, 'In Progress')),
              _stat('Resolved', inc.count(mine, 'Resolved')),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
          onPressed: () async {
            final yes = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Log out?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
                ],
              ),
            );
            if (yes == true && context.mounted) await context.read<AuthProvider>().logout();
          },
        ),
      ]),
    );
  }

  Widget _stat(String label, int n) => Column(children: [
        Text('$n', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]);
}

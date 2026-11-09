import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import '../widgets/summary_tile.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomeScreen({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inc = context.watch<IncidentProvider>();
    final isStaff = auth.isStaff;
    // Students see their own numbers; staff see campus-wide numbers.
    final scope = isStaff ? inc.all : inc.mine;
    final firstName = (auth.profile?.name ?? '').split(' ').first;

    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Hello, ${firstName.isEmpty ? 'there' : firstName}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(isStaff ? 'Review reports and update their status.' : 'Help make our campus safer.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('See an issue on campus?',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Report it and help improve our learning environment.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF6D28D9)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportFormScreen())),
              icon: const Icon(Icons.add_circle),
              label: const Text('Report an Issue'),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _header('Report Summary', onSeeAll),
        const SizedBox(height: 8),
        Row(children: [
          SummaryTile(icon: Icons.description_outlined, color: const Color(0xFF6D28D9), count: scope.length,
              label: isStaff ? 'All Reports' : 'My Reports'),
          SummaryTile(icon: Icons.timelapse, color: Colors.blue, count: inc.count(scope, 'In Progress'), label: 'In Progress'),
          SummaryTile(icon: Icons.check_circle_outline, color: const Color(0xFF16A34A), count: inc.count(scope, 'Resolved'), label: 'Resolved'),
          SummaryTile(icon: Icons.error_outline, color: Colors.red, count: inc.count(scope, 'Submitted'), label: 'Submitted'),
        ]),
        const SizedBox(height: 24),
        _header('Recent Reports', onSeeAll),
        const SizedBox(height: 8),
        if (inc.loading)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (inc.error != null)
          Text(inc.error!, style: const TextStyle(color: Colors.red))
        else if (inc.recent.isEmpty)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No reports yet.')))
        else
          ...inc.recent.map(IncidentCard.new),
      ]),
    );
  }

  Widget _header(String title, VoidCallback onTap) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onTap, child: const Text('See all')),
        ],
      );
}

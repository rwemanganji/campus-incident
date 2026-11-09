import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'report_form_screen.dart';
import 'reports_screen.dart';

/// Bottom navigation: Home, Reports, (centre) New report, Profile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: [
        HomeScreen(onSeeAll: () => setState(() => _index = 1)),
        const ReportsScreen(),
        const ProfileScreen(),
      ]),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Report an issue',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportFormScreen())),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _item(Icons.home_rounded, 'Home', 0),
          _item(Icons.list_alt_rounded, 'Reports', 1),
          const SizedBox(width: 48),
          _item(Icons.person_rounded, 'Profile', 2),
        ]),
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final selected = _index == i;
    final color = selected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      onTap: () => setState(() => _index = i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ]),
      ),
    );
  }
}

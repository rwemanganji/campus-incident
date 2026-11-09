import 'package:flutter/material.dart';

class SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  const SummaryTile({super.key, required this.icon, required this.color, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withAlpha(24), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ]),
      ),
    );
  }
}

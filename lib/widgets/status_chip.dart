import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppConstants.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withAlpha(32), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

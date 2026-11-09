import 'package:flutter/material.dart';

/// App-wide constants: allowed email domains, incident categories, statuses.
class AppConstants {
  static const allowedDomains = ['alustudent.com', 'alueducation.com'];
  static const categories = ['Facilities', 'Water', 'Electricity', 'Safety', 'Sanitation', 'Furniture'];
  static const statuses = ['Submitted', 'In Progress', 'Resolved'];
  static const locations = [
    'Block A', 'Block B', 'Block C', 'Student Residence',
    'Cafeteria', 'Library', 'Sports Field', 'Parking Lot', 'Other',
  ];

  static IconData categoryIcon(String c) {
    switch (c) {
      case 'Facilities': return Icons.apartment_rounded;
      case 'Water': return Icons.water_drop_outlined;
      case 'Electricity': return Icons.bolt_rounded;
      case 'Safety': return Icons.shield_outlined;
      case 'Sanitation': return Icons.delete_outline_rounded;
      case 'Furniture': return Icons.chair_alt_outlined;
      default: return Icons.report_problem_outlined;
    }
  }

  static Color statusColor(String s) {
    switch (s) {
      case 'Resolved': return const Color(0xFF16A34A);
      case 'In Progress': return const Color(0xFF6D28D9);
      default: return const Color(0xFFD97706);
    }
  }
}

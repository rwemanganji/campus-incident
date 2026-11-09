import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../widgets/incident_card.dart';

/// Browse, search and filter all reports.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inc = context.watch<IncidentProvider>();
    final list = inc.filtered;

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: inc.setQuery,
            decoration: const InputDecoration(hintText: 'Search reports', prefixIcon: Icon(Icons.search)),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            for (final s in [null, ...AppConstants.statuses])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(s ?? 'All'),
                  selected: inc.statusFilter == s,
                  onSelected: (_) => inc.setStatus(s),
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: inc.categoryFilter,
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All categories')),
                  for (final c in AppConstants.categories) DropdownMenuItem<String?>(value: c, child: Text(c)),
                ],
                onChanged: inc.setCategory,
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(label: const Text('My reports'), selected: inc.mineOnly, onSelected: (_) => inc.toggleMine()),
          ]),
        ),
        Expanded(
          child: inc.loading
              ? const Center(child: CircularProgressIndicator())
              : inc.error != null
                  ? Center(child: Text(inc.error!))
                  : list.isEmpty
                      ? const Center(child: Text('No reports match your filters.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: list.length,
                          itemBuilder: (_, i) => IncidentCard(list[i]),
                        ),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/match_provider.dart';
import 'package:tms_client/utils/time.dart';
import 'package:tms_client/views/match_controller/match_selector/accordion.dart';

class MatchSelector extends ConsumerWidget {
  const MatchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);
    final matchList = matches.entries.toList();

    // Sorter (sort by time)
    matchList.sort(
      (a, b) => a.value.startTime.toDateTime().compareTo(
        b.value.startTime.toDateTime(),
      ),
    );

    final completedMatches = matchList
        .where((entry) => entry.value.completed)
        .toList();
    final scheduledMatches = matchList
        .where((entry) => !entry.value.completed)
        .toList();

    if (matchList.isEmpty) {
      return const Center(child: Text('No matches'));
    }

    return Accordion(
      items: [
        AccordionItem(
          leading: Icon(Icons.check_circle),
          title: Text('Completed Matches (${completedMatches.length})'),
          child: completedMatches.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No completed matches'),
                  ),
                )
              : ListView.builder(
                  itemCount: completedMatches.length,
                  itemBuilder: (context, index) {
                    final entry = completedMatches[index];
                    return ListTile(
                      title: Text(entry.value.matchNumber),
                      subtitle: Text('ID: ${entry.key}'),
                    );
                  },
                ),
        ),
        AccordionItem(
          initiallyExpanded: true,
          leading: Icon(Icons.schedule),
          title: Text('Scheduled Matches (${scheduledMatches.length})'),
          child: scheduledMatches.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No scheduled matches'),
                  ),
                )
              : ListView.builder(
                  itemCount: scheduledMatches.length,
                  itemBuilder: (context, index) {
                    final entry = scheduledMatches[index];
                    return ListTile(
                      title: Text(entry.value.matchNumber),
                      subtitle: Text('ID: ${entry.key}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

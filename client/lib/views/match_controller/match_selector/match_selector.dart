import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/match_provider.dart';
import 'package:tms_client/utils/time.dart';
import 'package:tms_client/views/match_controller/match_selector/match_tile.dart';

class MatchSelector extends HookConsumerWidget {
  const MatchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);
    final matchList = matches.entries.toList();
    final tabController = useTabController(initialLength: 2);

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

    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Scheduled Matches'),
            Tab(text: 'Completed Matches'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              ListView.builder(
                itemCount: scheduledMatches.length,
                itemBuilder: (context, index) {
                  final entry = scheduledMatches[index];
                  return MatchTile(matchKey: entry.key, match: entry.value);
                },
              ),
              ListView.builder(
                itemCount: completedMatches.length,
                itemBuilder: (context, index) {
                  final entry = completedMatches[index];
                  return MatchTile(matchKey: entry.key, match: entry.value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

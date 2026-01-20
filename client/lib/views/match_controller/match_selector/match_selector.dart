import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/providers/match_provider.dart';
import 'package:tms_client/utils/statistics.dart';
import 'package:tms_client/utils/time.dart';
import 'package:tms_client/views/match_controller/match_selector/match_stats_header.dart';
import 'package:tms_client/views/match_controller/match_selector/match_tile.dart';

class MatchSelector extends HookConsumerWidget {
  const MatchSelector({super.key});

  Widget selectableEntry(MapEntry<String, GameMatch> entry) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
      child: MatchTile(matchKey: entry.key, match: entry.value),
    );
  }

  Widget breakIndicator(Duration duration) {
    final minutes = duration.inMinutes;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Break ($minutes min)',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  /// Calculate round number based on how many times the teams in the first match
  /// have appeared in completed matches (0-indexed)
  int calculateCurrentRound(
    List<MapEntry<String, GameMatch>> scheduledMatches,
    List<MapEntry<String, GameMatch>> completedMatches,
  ) {
    if (scheduledMatches.isEmpty) return 0;

    final firstMatch = scheduledMatches.first.value;
    final teamIds = firstMatch.assignments.map((a) => a.teamId).toSet();

    if (teamIds.isEmpty) return 0;

    // Count how many times each team has appeared in completed matches
    final Map<String, int> teamAppearances = {};
    for (final match in completedMatches) {
      for (final assignment in match.value.assignments) {
        if (teamIds.contains(assignment.teamId)) {
          teamAppearances[assignment.teamId] =
              (teamAppearances[assignment.teamId] ?? 0) + 1;
        }
      }
    }

    // Round is the minimum appearances of any team in the first match
    if (teamAppearances.isEmpty) return 0;
    return teamAppearances.values.reduce((a, b) => a < b ? a : b);
  }

  Widget selectableMatches(List<MapEntry<String, GameMatch>> matches) {
    if (matches.isEmpty) return const Center(child: Text('No Matches'));

    // Build list with break indicators
    final List<Widget> items = [];

    for (int i = 0; i < matches.length; i++) {
      // Check for break before this match (except first)
      if (i > 0) {
        final prevEndTime = matches[i - 1].value.startTime.toDateTime();
        final currentStartTime = matches[i].value.startTime.toDateTime();
        final gap = currentStartTime.difference(prevEndTime);
        if (gap.inMinutes >= 10) {
          items.add(breakIndicator(gap));
        }
      }
      items.add(selectableEntry(matches[i]));
    }

    return ListView(children: items);
  }

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
        .where(
          (entry) => !entry.value.assignments.every((a) => a.scoreSubmitted),
        )
        .toList();

    if (matchList.isEmpty) {
      return const Center(child: Text('No matches'));
    }

    final currentRound = calculateCurrentRound(
      scheduledMatches,
      completedMatches,
    );
    final totalMatches = matchList.length;
    final completedCount = completedMatches.length;

    final expectedCycleTime = getFirstPairCycleTime(
      matchList.map((e) => e.value).toList(),
    );

    final lastCycleTime = getLastPairCycleTime(
      completedMatches.map((e) => e.value).toList(),
    );

    return Column(
      children: [
        MatchStatsHeader(
          round: currentRound,
          completed: completedCount,
          total: totalMatches,
          expectedCycleTime: expectedCycleTime,
          lastCycleTime: lastCycleTime,
        ),
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
              selectableMatches(scheduledMatches),
              selectableMatches(completedMatches),
            ],
          ),
        ),
      ],
    );
  }
}

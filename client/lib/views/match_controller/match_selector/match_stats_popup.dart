import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/providers/match_provider.dart';
import 'package:tms_client/providers/table_name_provider.dart';
import 'package:tms_client/utils/statistics.dart';
import 'package:tms_client/utils/time.dart';

class MatchStatsPopup extends ConsumerWidget {
  const MatchStatsPopup({super.key});

  // Statistics
  // -- (Match Timing)
  // Last Cycle Time
  // Fastest Match
  // Fastest Cycle Time
  // Slowest Match
  // Slowest Cycle Time
  //
  // -- (Scoring Times)
  // <table_name> Last Cycle Time
  // ...
  // Fastest Table
  // Slowest Table
  // Average Total Scoring Time

  List<GameMatch> _convertToSortedList(Map<String, GameMatch> list) {
    return list.values.toList()..sort(
      (a, b) => a.startTime.toDateTime().compareTo(b.startTime.toDateTime()),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Color? _getCycleTimeColor(Duration? time, Duration? expected) {
    if (time == null || expected == null) return null;
    final diff = time.inSeconds - expected.inSeconds;
    if (diff > 30) {
      return Colors.red; // Behind schedule
    } else if (diff < -30) {
      return Colors.green; // Ahead of schedule
    }
    return null;
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statRow(
    BuildContext context,
    String label,
    String value, {
    String? subtitle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRowWithExpected(
    BuildContext context,
    String label,
    Duration? value,
    Duration? expected,
  ) {
    return _statRow(
      context,
      label,
      expected != null
          ? '${_formatDuration(value)} / ${_formatDuration(expected)}'
          : _formatDuration(value),
      valueColor: _getCycleTimeColor(value, expected),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedMatches = _convertToSortedList(
      ref.watch(completedMatchesProvider),
    );
    final incompleteMatches = _convertToSortedList(
      ref.watch(incompleteMatchesProvider),
    );
    final tableNames = ref.watch(tableNamesProvider);

    // Match Timing Stats
    final expectedCycleTime = getFirstPairCycleTime(incompleteMatches);
    final lastCycleTime = getLastPairCycleTime(completedMatches);
    final fastestCycleTime = getFastestCycleTime(completedMatches);
    final slowestCycleTime = getSlowestCycleTime(completedMatches);
    final averageCycleTime = getAverageCycleTime(completedMatches);
    final fastestMatch = getFastestMatch(completedMatches);
    final slowestMatch = getSlowestMatch(completedMatches);

    // Scoring Time Stats
    final tableIds = getAllTableIds(completedMatches);
    final fastestTable = getFastestTable(completedMatches);
    final slowestTable = getSlowestTable(completedMatches);
    final avgTotalScoringTime = getAverageTotalScoringTime(completedMatches);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Match Timing Section --
          _sectionHeader(context, 'Match Timing'),
          _statRowWithExpected(
            context,
            'Last Cycle Time',
            lastCycleTime,
            expectedCycleTime,
          ),
          _statRowWithExpected(
            context,
            'Average Cycle Time',
            averageCycleTime,
            expectedCycleTime,
          ),
          _statRowWithExpected(
            context,
            'Fastest Cycle Time',
            fastestCycleTime,
            expectedCycleTime,
          ),
          _statRowWithExpected(
            context,
            'Slowest Cycle Time',
            slowestCycleTime,
            expectedCycleTime,
          ),
          _statRow(
            context,
            'Fastest Match',
            _formatDuration(fastestMatch?.duration),
            subtitle: fastestMatch != null
                ? 'Match ${fastestMatch.match.matchNumber}'
                : null,
          ),
          _statRow(
            context,
            'Slowest Match',
            _formatDuration(slowestMatch?.duration),
            subtitle: slowestMatch != null
                ? 'Match ${slowestMatch.match.matchNumber}'
                : null,
          ),

          // -- Scoring Times Section --
          _sectionHeader(context, 'Scoring Times'),
          // Per-table last scoring times
          ...tableIds.map((tableId) {
            final tableName = tableNames[tableId]?.tableName ?? tableId;
            final lastTime = getLastTableScoringTime(completedMatches, tableId);
            return _statRow(
              context,
              '$tableName Last Score Time',
              '+${_formatDuration(lastTime)}',
            );
          }),
          const SizedBox(height: 8),
          _statRow(
            context,
            'Fastest Table',
            '+${_formatDuration(fastestTable?.avgTime)}',
            subtitle: fastestTable != null
                ? '${tableNames[fastestTable.tableId]?.tableName ?? fastestTable.tableId} (${fastestTable.tableId})'
                : null,
          ),
          _statRow(
            context,
            'Slowest Table',
            '+${_formatDuration(slowestTable?.avgTime)}',
            subtitle: slowestTable != null
                ? '${tableNames[slowestTable.tableId]?.tableName ?? slowestTable.tableId} (${slowestTable.tableId})'
                : null,
          ),
          _statRow(
            context,
            'Average Scoring Time',
            '+${_formatDuration(avgTotalScoringTime)}',
          ),
        ],
      ),
    );
  }
}

import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/utils/time.dart';

Duration calculateMatchCycleTime(GameMatch m1, GameMatch m2) {
  final first = m1.startTime.toDateTime();
  final second = m2.startTime.toDateTime();
  return second.difference(first);
}

Duration? getFirstPairCycleTime(List<GameMatch> matches) {
  final first = matches.elementAtOrNull(0);
  final second = matches.elementAtOrNull(1);
  if (first == null || second == null) return null;
  return calculateMatchCycleTime(first, second);
}

Duration? getLastPairCycleTime(List<GameMatch> matches) {
  final secondLastIndex = matches.length - 2;
  if (secondLastIndex < 0) return null;
  final secondLast = matches.elementAtOrNull(secondLastIndex);
  final last = matches.lastOrNull;
  if (secondLast == null || last == null) return null;
  return calculateMatchCycleTime(secondLast, last);
}

// -- Match Timing Statistics --

/// Get all cycle times between consecutive matches
List<Duration> getAllCycleTimes(List<GameMatch> matches) {
  final cycleTimes = <Duration>[];
  for (int i = 1; i < matches.length; i++) {
    final prev = matches.elementAtOrNull(i - 1);
    final curr = matches.elementAtOrNull(i);
    if (prev != null && curr != null) {
      cycleTimes.add(calculateMatchCycleTime(prev, curr));
    }
  }
  return cycleTimes;
}

/// Get the fastest cycle time from completed matches
Duration? getFastestCycleTime(List<GameMatch> matches) {
  final cycleTimes = getAllCycleTimes(matches);
  if (cycleTimes.isEmpty) return null;
  return cycleTimes.reduce((a, b) => a < b ? a : b);
}

/// Get the slowest cycle time from completed matches
Duration? getSlowestCycleTime(List<GameMatch> matches) {
  final cycleTimes = getAllCycleTimes(matches);
  if (cycleTimes.isEmpty) return null;
  return cycleTimes.reduce((a, b) => a > b ? a : b);
}

/// Get the average cycle time from completed matches
Duration? getAverageCycleTime(List<GameMatch> matches) {
  final cycleTimes = getAllCycleTimes(matches);
  if (cycleTimes.isEmpty) return null;
  final totalMs = cycleTimes.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
  return Duration(milliseconds: totalMs ~/ cycleTimes.length);
}

/// Calculate match duration (from start to completion)
Duration? getMatchDuration(GameMatch match) {
  if (!match.completed) return null;
  final start = match.startTime.toDateTime();
  final end = match.completedAt.toDateTime();
  return end.difference(start);
}

/// Get the fastest match by duration
({GameMatch match, Duration duration})? getFastestMatch(
  List<GameMatch> matches,
) {
  GameMatch? fastest;
  Duration? fastestDuration;

  for (final match in matches) {
    final duration = getMatchDuration(match);
    if (duration != null) {
      if (fastestDuration == null || duration < fastestDuration) {
        fastest = match;
        fastestDuration = duration;
      }
    }
  }

  if (fastest == null || fastestDuration == null) return null;
  return (match: fastest, duration: fastestDuration);
}

/// Get the slowest match by duration
({GameMatch match, Duration duration})? getSlowestMatch(
  List<GameMatch> matches,
) {
  GameMatch? slowest;
  Duration? slowestDuration;

  for (final match in matches) {
    final duration = getMatchDuration(match);
    if (duration != null) {
      if (slowestDuration == null || duration > slowestDuration) {
        slowest = match;
        slowestDuration = duration;
      }
    }
  }

  if (slowest == null || slowestDuration == null) return null;
  return (match: slowest, duration: slowestDuration);
}

// -- Scoring Time Statistics --

/// Get scoring duration for a specific table assignment (time from match completion to score submission)
Duration? getTableScoringDuration(GameMatch match, TableAssignment assignment) {
  if (!match.completed || !assignment.scoreSubmitted) return null;
  final matchCompleted = match.completedAt.toDateTime();
  final scoreTime = assignment.scoreSubmittedAt.toDateTime();
  return scoreTime.difference(matchCompleted);
}

/// Get all scoring times for a specific table across all matches
List<Duration> getTableScoringTimes(List<GameMatch> matches, String tableId) {
  final times = <Duration>[];
  for (final match in matches) {
    for (final assignment in match.assignments) {
      if (assignment.tableId == tableId && assignment.scoreSubmitted) {
        final duration = getTableScoringDuration(match, assignment);
        if (duration != null) {
          times.add(duration);
        }
      }
    }
  }
  return times;
}

/// Get average scoring time for a specific table
Duration? getAverageTableScoringTime(List<GameMatch> matches, String tableId) {
  final times = getTableScoringTimes(matches, tableId);
  if (times.isEmpty) return null;
  final totalMs = times.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
  return Duration(milliseconds: totalMs ~/ times.length);
}

/// Get the last scoring time for a specific table
Duration? getLastTableScoringTime(List<GameMatch> matches, String tableId) {
  // Sort by completed_at descending to find most recent
  final sorted = matches.where((m) => m.completed).toList()
    ..sort(
      (a, b) =>
          b.completedAt.toDateTime().compareTo(a.completedAt.toDateTime()),
    );

  for (final match in sorted) {
    for (final assignment in match.assignments) {
      if (assignment.tableId == tableId && assignment.scoreSubmitted) {
        return getTableScoringDuration(match, assignment);
      }
    }
  }
  return null;
}

/// Get all unique table IDs from matches
Set<String> getAllTableIds(List<GameMatch> matches) {
  final tableIds = <String>{};
  for (final match in matches) {
    for (final assignment in match.assignments) {
      tableIds.add(assignment.tableId);
    }
  }
  return tableIds;
}

/// Get the fastest table by average scoring time
({String tableId, Duration avgTime})? getFastestTable(List<GameMatch> matches) {
  final tableIds = getAllTableIds(matches);
  String? fastestTable;
  Duration? fastestTime;

  for (final tableId in tableIds) {
    final avgTime = getAverageTableScoringTime(matches, tableId);
    if (avgTime != null) {
      if (fastestTime == null || avgTime < fastestTime) {
        fastestTable = tableId;
        fastestTime = avgTime;
      }
    }
  }

  if (fastestTable == null || fastestTime == null) return null;
  return (tableId: fastestTable, avgTime: fastestTime);
}

/// Get the slowest table by average scoring time
({String tableId, Duration avgTime})? getSlowestTable(List<GameMatch> matches) {
  final tableIds = getAllTableIds(matches);
  String? slowestTable;
  Duration? slowestTime;

  for (final tableId in tableIds) {
    final avgTime = getAverageTableScoringTime(matches, tableId);
    if (avgTime != null) {
      if (slowestTime == null || avgTime > slowestTime) {
        slowestTable = tableId;
        slowestTime = avgTime;
      }
    }
  }

  if (slowestTable == null || slowestTime == null) return null;
  return (tableId: slowestTable, avgTime: slowestTime);
}

/// Get average total scoring time across all tables
Duration? getAverageTotalScoringTime(List<GameMatch> matches) {
  final allTimes = <Duration>[];
  for (final match in matches) {
    for (final assignment in match.assignments) {
      if (assignment.scoreSubmitted) {
        final duration = getTableScoringDuration(match, assignment);
        if (duration != null) {
          allTimes.add(duration);
        }
      }
    }
  }
  if (allTimes.isEmpty) return null;
  final totalMs = allTimes.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
  return Duration(milliseconds: totalMs ~/ allTimes.length);
}

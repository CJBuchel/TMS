import 'package:tms/schema/tms_schema.dart';

DateTime? _parseStringTime(String time) {
  final format24 = RegExp(r'^(\d{2}):(\d{2}):(\d{2}) (AM|PM)$');
  final matchTime = format24.firstMatch(time); // heh, matching match time
  if (matchTime != null) {
    final hour = int.parse(matchTime.group(1)!);
    final minute = int.parse(matchTime.group(2)!);
    final second = int.parse(matchTime.group(3)!);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  } else {
    return null;
  }
}

List<GameMatch> sortMatchesByTime(List<GameMatch> matches) {
  final originalIndices = Map.fromEntries(matches.asMap().entries.map((e) => MapEntry(e.value, e.key)));

  matches.sort((a, b) {
    final aTime = _parseStringTime(a.startTime);
    final bTime = _parseStringTime(b.startTime);
    if (aTime != null && bTime != null) {
      if (aTime == bTime) {
        return originalIndices[a]!.compareTo(originalIndices[b]!);
      }
      return aTime.compareTo(bTime);
    } else {
      return 0;
    }
  });
  return matches;
}

List<Team> sortTeamsByRank(List<Team> teams) {
  final originalIndices = Map.fromEntries(teams.asMap().entries.map((e) => MapEntry(e.value, e.key)));

  teams.sort((a, b) {
    if (a.ranking == b.ranking) {
      return originalIndices[a]!.compareTo(originalIndices[b]!);
    }
    return a.ranking.compareTo(b.ranking);
  });

  return teams;
}

List<Team> sortTeamsByNumber(List<Team> teams) {
  final originalIndices = Map.fromEntries(teams.asMap().entries.map((e) => MapEntry(e.value, e.key)));

  teams.sort((a, b) {
    final aNumber = int.tryParse(a.teamNumber.replaceAll(RegExp(r'[^0-9]'), ''));
    final bNumber = int.tryParse(b.teamNumber.replaceAll(RegExp(r'[^0-9]'), ''));
    if (aNumber == null && bNumber == null) {
      return 0;
    } else if (aNumber == null) {
      return 1;
    } else if (bNumber == null) {
      return -1;
    } else {
      final result = aNumber.compareTo(bNumber);
      if (result == 0) {
        return originalIndices[a]!.compareTo(originalIndices[b]!);
      }
      return result;
    }
  });

  return teams;
}

List<JudgingSession> sortJudgingByTime(List<JudgingSession> judging) {
  final originalIndices = Map.fromEntries(judging.asMap().entries.map((e) => MapEntry(e.value, e.key)));

  judging.sort((a, b) {
    final aTime = _parseStringTime(a.startTime);
    final bTime = _parseStringTime(b.startTime);
    if (aTime != null && bTime != null) {
      if (aTime == bTime) {
        return originalIndices[a]!.compareTo(originalIndices[b]!);
      }
      return aTime.compareTo(bTime);
    } else {
      return 0;
    }
  });
  return judging;
}

List<Backup> sortBackupsByDate(List<Backup> backups) {
  var sortedBackups = backups..sort((a, b) => b.unixTimestamp.compareTo(a.unixTimestamp));
  return sortedBackups;
}

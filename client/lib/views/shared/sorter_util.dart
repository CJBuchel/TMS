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
  matches.sort((a, b) {
    final aTime = _parseStringTime(a.startTime);
    final bTime = _parseStringTime(b.startTime);
    if (aTime != null && bTime != null) {
      return aTime.compareTo(bTime);
    } else {
      return 0;
    }
  });
  return matches;
}

List<Team> sortTeamsByRank(List<Team> teams) {
  Set<int> uniqueRanks = teams.map((e) => e.ranking).toSet();

  if (uniqueRanks.length == 1) {
    return teams;
  } else {
    teams.sort((a, b) {
      return a.ranking.compareTo(b.ranking);
    });
    return teams;
  }
}

List<JudgingSession> sortJudgingByTime(List<JudgingSession> judging) {
  judging.sort((a, b) {
    final aTime = _parseStringTime(a.startTime);
    final bTime = _parseStringTime(b.startTime);
    if (aTime != null && bTime != null) {
      return aTime.compareTo(bTime);
    } else {
      return 0;
    }
  });
  return judging;
}

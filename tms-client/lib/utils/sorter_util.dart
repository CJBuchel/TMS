import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/utils/tms_time_utils.dart';

List<GameMatch> sortMatchesByTime(List<GameMatch> matches) {
  matches.sort((a, b) {
    return tmsDateTimeCompare(a.startTime, b.startTime);
  });

  return matches;
}

List<GameMatch> sortMatchesByMatchNumber(List<GameMatch> matches) {
  // sort by match number and try parse
  matches.sort((a, b) {
    int aMatchNumber = int.tryParse(a.matchNumber) ?? 0;
    int bMatchNumber = int.tryParse(b.matchNumber) ?? 0;
    return aMatchNumber.compareTo(bMatchNumber);
  });

  return matches;
}

int _extractNumber(String str) {
  final regex = RegExp(r'\d+');
  final match = regex.firstMatch(str);
  if (match != null) {
    return int.parse(match.group(0)!);
  }
  return 0;
}

List<Team> sortTeamsByNumber(List<Team> teams) {
  teams.sort((a, b) {
    int aTeamNumber = _extractNumber(a.teamNumber);
    int bTeamNumber = _extractNumber(b.teamNumber);
    return aTeamNumber.compareTo(bTeamNumber);
  });

  return teams;
}

List<Team> sortTeamsByRanking(List<Team> teams) {
  teams.sort((a, b) {
    return a.ranking.compareTo(b.ranking);
  });

  return teams;
}

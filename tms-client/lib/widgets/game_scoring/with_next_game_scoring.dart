import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/providers/game_table_provider.dart';
import 'package:tms/providers/teams_provider.dart';

class _NextData {
  final GameMatch? nextMatch;
  final Team? nextTeam;
  final int lengthMatches;
  final int round;

  _NextData({
    required this.nextMatch,
    required this.nextTeam,
    required this.lengthMatches,
    required this.round,
  });
}

class WithNextGameScoring extends StatelessWidget {
  final Widget Function(BuildContext context, GameMatch? nextMatch, Team? nextTeam, int totalMatches, int round)
      builder;

  const WithNextGameScoring({Key? key, required this.builder}) : super(key: key);

  int getRound(String teamNumber, String currentMatchNumber, List<GameMatch> matches) {
    int round = 0;
    for (GameMatch match in matches) {
      if (match.gameMatchTables.any((e) => e.teamNumber == teamNumber)) {
        round++;
      }
      if (match.matchNumber == currentMatchNumber) {
        break;
      }
    }
    return round;
  }

  @override
  Widget build(BuildContext context) {
    return Selector3<GameTableProvider, GameMatchProvider, TeamsProvider, _NextData>(
      selector: (context, gameTableProvider, gameMatchProvider, teamsProvider) {
        final gameTable = gameTableProvider.localGameTable;
        final gameMatch = gameMatchProvider.getNextTableMatch(gameTable);

        final gameMatchTable = gameMatch?.gameMatchTables.firstWhere((e) => e.table == gameTable);
        final teamNumber = gameMatchTable?.teamNumber;

        int lengthMatches = gameMatchProvider.matches.length;
        int round = 0;

        if (teamNumber != null) {
          final team = teamsProvider.getTeam(teamNumber);
          // get the round number for this team
          // based on how many times it's popped up until this match
          if (gameMatch != null) round = getRound(teamNumber, gameMatch.matchNumber, gameMatchProvider.matches);

          return _NextData(
            nextMatch: gameMatch,
            nextTeam: team,
            lengthMatches: lengthMatches,
            round: round,
          );
        } else {
          return _NextData(
            nextMatch: null,
            nextTeam: null,
            lengthMatches: lengthMatches,
            round: round,
          );
        }
      },
      shouldRebuild: (previous, next) {
        return previous.nextMatch != next.nextMatch ||
            previous.nextTeam != next.nextTeam ||
            previous.lengthMatches != next.lengthMatches ||
            previous.round != next.round;
      },
      builder: (context, data, _) {
        return builder(context, data.nextMatch, data.nextTeam, data.lengthMatches, data.round);
      },
    );
  }
}

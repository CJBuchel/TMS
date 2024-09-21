import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/judging_sessions_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';
import 'package:tms/providers/teams_provider.dart';

class _TeamDetailsData {
  final Team team;
  final List<GameMatch> teamMatches;
  final List<JudgingSession> teamSessions;
  final List<GameScoreSheet> teamScores;

  _TeamDetailsData({
    required this.team,
    required this.teamMatches,
    required this.teamSessions,
    required this.teamScores,
  });
}

class WithTeamDetails extends StatelessWidget {
  final String teamId;
  final Widget Function(
    BuildContext context,
    Team team,
    List<GameMatch> teamMatches,
    List<JudgingSession> teamSessions,
    List<GameScoreSheet> teamScores,
  ) builder;

  const WithTeamDetails({
    Key? key,
    required this.teamId,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector4<GameMatchProvider, JudgingSessionsProvider, GameScoresProvider, TeamsProvider, _TeamDetailsData>(
      selector: (context, a, b, c, d) {
        Team team = d.getTeamById(teamId);
        return _TeamDetailsData(
          team: d.getTeamById(teamId),
          teamMatches: a.getMatchesByTeamNumber(team.teamNumber),
          teamSessions: b.getSessionsByTeamNumber(teamId),
          teamScores: c.getScoresByTeamId(teamId),
        );
      },
      shouldRebuild: (previous, next) {
        bool isEqual = true;
        isEqual = isEqual && listEquals(previous.teamMatches, next.teamMatches);
        isEqual = isEqual && listEquals(previous.teamSessions, next.teamSessions);
        isEqual = isEqual && listEquals(previous.teamScores, next.teamScores);
        return !isEqual;
      },
      builder: (context, value, child) {
        return builder(
          context,
          value.team,
          value.teamMatches,
          value.teamSessions,
          value.teamScores,
        );
      },
    );
  }
}

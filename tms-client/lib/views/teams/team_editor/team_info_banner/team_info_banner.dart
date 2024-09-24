import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/judging_sessions_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/views/teams/team_editor/team_info_banner/delete_team_button.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';

class TeamInfoBanner extends StatelessWidget {
  final String teamId;
  final Team team;

  const TeamInfoBanner({
    Key? key,
    required this.teamId,
    required this.team,
  }) : super(key: key);

  Widget _matchesInfo() {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (_, p) => p.getMatchesByTeamNumber(team.teamNumber),
      shouldRebuild: (previous, next) => !listEquals(previous, next),
      builder: (_, gameMatches, __) {
        int completedRounds = gameMatches.where((match) => match.completed).length;
        return Row(
          children: [
            // checks
            Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
              selector: (_, p) {
                return gameMatches.map((match) {
                  return p.getMatchMessages(match.matchNumber);
                }).expand((element) {
                  return element;
                }).toList();
              },
              builder: (context, messages, child) {
                return IconTooltipIntegrityCheck(messages: messages);
              },
            ),

            Text("Matches: $completedRounds/${gameMatches.length}"),
          ],
        );
      },
    );
  }

  Widget _teamInfo() {
    return Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
      selector: (_, p) => p.getTeamMessages(team.teamNumber),
      builder: (context, messages, child) {
        return Row(
          children: [
            IconTooltipIntegrityCheck(messages: messages),
            Text("Team issues: ${messages.length}"),
          ],
        );
      },
    );
  }

  Widget _judgingSessionsInfo() {
    return Selector<JudgingSessionsProvider, List<JudgingSession>>(
      selector: (_, p) => p.getSessionsByTeamNumber(team.teamNumber),
      shouldRebuild: (previous, next) => !listEquals(previous, next),
      builder: (_, sessions, __) {
        int completedSessions = sessions.where((session) => session.completed).length;
        return Row(
          children: [
            // checks
            Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
              selector: (_, p) {
                return sessions.map((session) {
                  return p.getSessionMessages(session.sessionNumber);
                }).expand((element) {
                  return element;
                }).toList();
              },
              builder: (context, messages, child) {
                return IconTooltipIntegrityCheck(messages: messages);
              },
            ),

            Text("Judging Sessions: $completedSessions/${sessions.length}"),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      // color: Colors.deepPurple[900],
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // matches
          _matchesInfo(),
          // judging sessions
          _judgingSessionsInfo(),
          // team/game scores
          _teamInfo(),
          // delete button
          DeleteTeamButton(teamId: teamId),
        ],
      ),
    );
  }
}

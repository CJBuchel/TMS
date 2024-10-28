import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/models/team_data_model.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/team_data/team_data_filter_table.dart';

class TeamData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":teams",
        ":robot_game:game_scores",
      ],
      child: Selector2<TeamsProvider, GameScoresProvider, List<TeamDataModel>>(
        selector: (_, tp, gsp) {
          List<TeamDataModel> data = tp.teamsMap.entries.map((element) {
            final teamId = element.key;
            final team = element.value;
            final scores = gsp.getScoresByTeamId(teamId);
            return TeamDataModel(teamId, team, scores);
          }).toList();

          return TeamDataModel.sort(data);
        },
        builder: (context, data, _) {
          int maxNumberRounds = 0;

          for (var teamData in data) {
            for (var score in teamData.scores) {
              if (score.round > maxNumberRounds) {
                maxNumberRounds = score.round;
              }
            }
          }

          return TeamDataFilterTable(
            maxNumberRounds: maxNumberRounds,
            teamData: data,
          );
        },
      ),
    );
  }
}

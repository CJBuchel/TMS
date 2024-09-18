import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/scoreboard/team_scoring_data.dart';
import 'package:tms/views/scoreboard/teams_ranking_list/teams_ranking_header.dart';
import 'package:tms/views/scoreboard/teams_ranking_list/teams_ranking_row.dart';
import 'package:tms/widgets/animated/infinite_vertical_list.dart';

class TeamsRankingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double childHeight = 40;

    return Selector2<TeamsProvider, GameScoresProvider, List<TeamScoringData>>(
      selector: (context, teamsProvider, gameScoresProvider) {
        List<TeamScoringData> teamScoringData = teamsProvider.teamsMap.entries.map((e) {
          return TeamScoringData(
            teamRank: e.value.ranking,
            teamId: e.key,
            teamNumber: e.value.teamNumber,
            teamName: e.value.name,
            scores: gameScoresProvider.getScoresByTeamId(e.key),
          );
        }).toList();

        // first sort by team number (stops teams jumping around)
        teamScoringData.sort((a, b) {
          final regex = RegExp(r'\d+');
          final matchA = regex.firstMatch(a.teamNumber);
          final matchB = regex.firstMatch(b.teamNumber);
          if (matchA != null && matchB != null) {
            int aTeamNumber = int.parse(matchA.group(0)!);
            int bTeamNumber = int.parse(matchB.group(0)!);
            return aTeamNumber.compareTo(bTeamNumber);
          } else {
            return a.teamNumber.compareTo(b.teamNumber);
          }
        });
        // then sort by team rank
        teamScoringData.sort((a, b) => a.teamRank.compareTo(b.teamRank));
        return teamScoringData;
      },
      builder: (context, teamsData, child) {
        int numRounds = teamsData.fold(0, (max, teamData) {
          return teamData.scores.length > max ? teamData.scores.length : max;
        });

        return Column(
          children: [
            Container(
              height: childHeight,
              child: TeamsRankingHeader(numRounds: numRounds),
            ),
            Expanded(
              child: AnimatedInfiniteVerticalList(
                childHeight: childHeight,
                children: teamsData.asMap().entries.map((entry) {
                  int index = entry.key;

                  Color? evenLightBackground = Theme.of(context).scaffoldBackgroundColor;
                  Color? oddLightBackground = Theme.of(context).cardColor;

                  Color? evenDarkBackground = Theme.of(context).scaffoldBackgroundColor;
                  Color? oddDarkBackground = lighten(Theme.of(context).scaffoldBackgroundColor, 0.05);

                  Color? evenBackground =
                      Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
                  Color? oddBackground =
                      Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

                  Color? rowColor = index % 2 == 0 ? evenBackground : oddBackground;
                  Color? bestScoreColor = index % 2 == 0 ? oddBackground : evenBackground;
                  return Container(
                    height: childHeight,
                    color: rowColor,
                    // child: _teamRow(context, entry.value, numRounds, index),
                    child: TeamsRankingRow(numRounds: numRounds, teamData: entry.value, bestScoreColor: bestScoreColor),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

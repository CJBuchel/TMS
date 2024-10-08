import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/dashboard/scoring_overview/scoring_tile.dart/scoring_overview_tile.dart';

class ScoringOverview extends StatelessWidget {
  const ScoringOverview({Key? key}) : super(key: key);

  Widget _scoringItem(BuildContext context, int listIndex, TeamScoreSheet teamScoreSheet) {
    Color evenBackground = Theme.of(context).cardColor;
    Color oddBackground = lighten(Theme.of(context).cardColor, 0.05);

    Color backgroundColor = listIndex % 2 == 0 ? evenBackground : oddBackground;
    return ScoreOverviewTile(
      backgroundColor: backgroundColor,
      teamScoreSheet: teamScoreSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameScoresProvider, List<TeamScoreSheet>>(
      selector: (context, p) {
        var scores = p.scoresWithId.map((e) {
          return TeamScoreSheet(
            scoreSheet: e.$2,
            scoreSheetId: e.$1,
          );
        }).toList();

        return scores.reversed.toList(); // reverse so newest scores are at the top
      },
      builder: (context, scores, _) {
        Color mainColor = Colors.green;

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: mainColor),
              left: BorderSide(color: mainColor),
              right: BorderSide(color: mainColor),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Scores",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              // scores
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: scores.map((s) {
                      return _scoringItem(
                        context,
                        scores.indexOf(s),
                        s,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

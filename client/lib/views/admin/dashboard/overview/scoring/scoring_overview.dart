import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/admin/dashboard/overview/scoring/scoring_tile_widgets.dart';

class TeamScoreWidget {
  final String teamNumber;
  final int timeStamp;
  final Widget scoreWidget;
  const TeamScoreWidget({
    required this.teamNumber,
    required this.timeStamp,
    required this.scoreWidget,
  });
}

class ScoringOverview extends StatelessWidget {
  final ValueNotifier<List<Team>> teamsNotifier;
  const ScoringOverview({Key? key, required this.teamsNotifier}) : super(key: key);

  List<TeamScoreWidget> sortScoresByTimeStamp(List<TeamScoreWidget> scores) {
    // convert timestamp to datetime
    scores.sort((a, b) {
      DateTime aTime = parseServerTimestamp(a.timeStamp);
      DateTime bTime = parseServerTimestamp(b.timeStamp);
      return aTime.compareTo(bTime);
    });

    return scores;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: teamsNotifier,
      builder: (context, List<Team> teams, _) {
        // create map of all the scoresheets (timestamp teamNumber, )
        List<TeamScoreWidget> scoresheets = [];
        for (Team t in teams) {
          // game scores
          for (TeamGameScore ts in t.gameScores) {
            scoresheets.add(
              TeamScoreWidget(
                teamNumber: t.teamNumber,
                timeStamp: ts.timeStamp,
                scoreWidget: GameScoringTile(
                  teamNumber: t.teamNumber,
                  gameScore: ts,
                  scores: t.gameScores,
                ),
              ),
            );
          }
        }

        // sort them
        scoresheets = sortScoresByTimeStamp(scoresheets).reversed.toList();

        return ListView.builder(
          itemCount: scoresheets.length,
          itemBuilder: (context, index) {
            return Card(
              child: scoresheets[index].scoreWidget,
            );
          },
        );
      },
    );
  }
}

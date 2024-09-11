import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/utils/score_tags.dart';
import 'package:tms/views/admin/dashboard/overview/scoring/edit_score.dart';

class GameScoringTile extends StatelessWidget {
  final String teamNumber;
  final TeamGameScore gameScore;
  final List<TeamGameScore> scores;
  const GameScoringTile({
    Key? key,
    required this.teamNumber,
    required this.scores,
    required this.gameScore,
  }) : super(key: key);

  Widget _styledCell(Widget inner) {
    return Center(
      child: inner,
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        // border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: _styledCell(Text(teamNumber)),
          ),
          Expanded(
            flex: 1,
            child: _styledCell(Text("R${gameScore.scoresheet.round}")),
          ),
          Expanded(
            flex: 1,
            child: _styledCell(Text(gameScore.referee)),
          ),
          Expanded(
            flex: 1,
            child: _styledCell(
              Text(
                "${gameScore.score}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _tile(BuildContext context) {
    String timestamp = parseDateTimeToString(parseServerTimestamp(gameScore.timeStamp));
    return ListTile(
      title: _title(context),
      subtitle: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  timestamp,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: GameScoreTags(score: gameScore, scores: scores).get(),
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        EditOverviewScore(
          teamNumber: teamNumber,
          gameScore: gameScore,
        ).show(context);
      },
    );
  }

  // games = purple
  // cv  = red
  // rd = green
  // ip = blue
  @override
  Widget build(BuildContext context) {
    // create the dipped in pain effect
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black),
        gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.center, colors: [
          Colors.purple,
          Colors.purple,
          Colors.transparent,
        ], stops: [
          0.0,
          0.05,
          0.05,
        ]),
      ),
      child: Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: _tile(context)),
    );
  }
}

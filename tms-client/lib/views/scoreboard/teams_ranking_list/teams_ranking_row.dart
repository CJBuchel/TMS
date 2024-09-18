import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/views/scoreboard/team_scoring_data.dart';

class TeamsRankingRow extends StatelessWidget {
  final int numRounds;
  final TeamScoringData teamData;
  final Color? bestScoreColor;

  const TeamsRankingRow({
    Key? key,
    required this.numRounds,
    required this.teamData,
    this.bestScoreColor,
  }) : super(key: key);

  Widget _getRankIcon(int rank) {
    if (rank == 1) {
      return const Icon(Icons.looks_one_outlined);
    } else if (rank == 2) {
      return const Icon(Icons.looks_two_outlined);
    } else if (rank == 3) {
      return const Icon(Icons.looks_3_outlined);
    } else {
      return const Text("");
    }
  }

  Widget _getRankWidget(int rank) {
    if (rank > 3) {
      return Text("$rank");
    } else {
      return _getRankIcon(rank);
    }
  }

  Widget _bestScoreWidget(BuildContext context, List<int> scores) {
    if (scores.isNotEmpty) {
      return Center(
        child: Container(
          height: 30,
          width: 100,
          decoration: ShapeDecoration(
            color: bestScoreColor,
            shape: BeveledRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              side: BorderSide(
                width: 0.3,
                color: Theme.of(context).brightness == Brightness.light ? Colors.black26 : Colors.white24,
              ),
            ),
          ),
          child: Center(
            child: Text("${scores.reduce((value, element) => value > element ? value : element)}"),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<Widget> _scoreColumns(BuildContext context, List<GameScoreSheet> scores) {
    List<Widget> scoreColumns = [];

    // add best score first if there are multiple scores
    if (numRounds > 1) {
      scoreColumns.add(
        Expanded(
          flex: 1,
          child: _bestScoreWidget(context, scores.map((score) => score.score).toList()),
        ),
      );
    }

    // add all scores
    scoreColumns.addAll(
      List.generate(numRounds, (index) {
        if (index < scores.length) {
          List<int> scoreValues = scores.where((score) => score.round == index + 1).map((score) {
            return score.score;
          }).toList();

          String strScore = scoreValues.isEmpty ? "?" : scoreValues.first.toString();
          strScore = scoreValues.length > 1 ? "Conflict" : strScore;

          return Expanded(
            flex: 1,
            child: Center(
              child: Text(strScore),
            ),
          );
        } else {
          return const Expanded(
            flex: 1,
            child: const SizedBox.shrink(),
          );
        }
      }),
    );

    return scoreColumns;
  }

  @override
  Widget build(BuildContext context) {
    // List<int> scores = _teamScores(teamData.scores);
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: _getRankWidget(teamData.teamRank),
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: Text(teamData.teamName),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: _scoreColumns(context, teamData.scores),
          ),
        ),
      ],
    );
  }
}

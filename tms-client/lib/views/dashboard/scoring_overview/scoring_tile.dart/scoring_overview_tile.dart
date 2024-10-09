import 'package:flutter/material.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/views/dashboard/scoring_overview/scoring_tile.dart/score_center_info.dart';
import 'package:tms/widgets/dialogs/edit_game_score_dialog.dart';
import 'package:tms/widgets/team_widgets/team_score_sheet_tags.dart';

class ScoreOverviewTile extends StatelessWidget {
  final Color backgroundColor;
  final TeamScoreSheet teamScoreSheet;

  const ScoreOverviewTile({
    required this.backgroundColor,
    required this.teamScoreSheet,
  });

  Widget _leading() {
    return const Icon(Icons.sports_esports);
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;

    return Card(
      margin: const EdgeInsets.all(10),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        leading: _leading(),
        title: ScoreCenterInfo(
          backgroundColor: backgroundColor,
          teamScoreSheet: teamScoreSheet.scoreSheet,
        ),
        trailing: IconButton(
          onPressed: () => EditGameScoreDialog(
            score: teamScoreSheet,
          ).show(context),
          icon: const Icon(Icons.edit, color: Colors.blue),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 10, // space between items
                runSpacing: 5, // space between lines
                children: [
                  // timestamp
                  Text(
                    "${teamScoreSheet.scoreSheet.timestamp.time.toString()},",
                    // make italic and bold
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // match
                  Text(
                    "Match ${teamScoreSheet.scoreSheet.matchNumber ?? "N/A"},",
                    // make italic and bold
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // round
                  Text(
                    "Round ${teamScoreSheet.scoreSheet.round},",
                    // make italic and bold
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // referee
                  Text(
                    teamScoreSheet.scoreSheet.referee,
                    // make italic and bold
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // tags, align these at the end
                  Container(
                    width: constraints.maxWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TeamScoreSheetTags(
                          gameScoreSheet: teamScoreSheet.scoreSheet,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

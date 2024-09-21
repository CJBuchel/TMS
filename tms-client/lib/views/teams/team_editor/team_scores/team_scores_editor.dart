import 'package:flutter/material.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/services/game_scoring_service.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/views/teams/team_editor/team_scores/on_edit_score.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class TeamScoresEditor extends StatelessWidget {
  final String teamId;
  final List<TeamScoreSheet> teamScores;

  TeamScoresEditor({
    Key? key,
    required this.teamId,
    required this.teamScores,
  }) : super(key: key);

  final ExpansionController _expansionController = ExpansionController();

  BaseTableCell _cell(Widget child) {
    return BaseTableCell(
      child: Center(child: child),
    );
  }

  List<EditTableRow> _editTableRows(BuildContext context) {
    teamScores.sort((a, b) {
      return a.scoreSheet.timestamp.compareTo(other: b.scoreSheet.timestamp);
    });
    return teamScores.map((score) {
      return EditTableRow(
        onDelete: () {
          ConfirmFutureDialog(
            style: ConfirmDialogStyle.error(
              title: 'Delete Score',
              message: const Text('Are you sure you want to delete this score?'),
            ),
            onStatusConfirmFuture: () => GameScoringService().removeScoreSheet(score.scoreSheetId),
          ).show(context);
        },
        onEdit: () => OnEditScore(context: context, score: score).call(),
        cells: [
          // Timestamp
          _cell(Text(tmsDateTimeToString(score.scoreSheet.timestamp))),
          // Round
          _cell(Text(score.scoreSheet.round.toString())),
          // Table
          _cell(Text(score.scoreSheet.table)),
          // Referee
          _cell(Text(score.scoreSheet.referee)),
          // Score
          _cell(Text(score.scoreSheet.score.toString())),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpandableTile(
        controller: _expansionController,
        header: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const Text(
                "Team Scores",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _expansionController,
                builder: (context, isExpanded, _) {
                  return Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: lighten(Theme.of(context).cardColor, 0.05),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: EditTable(
            headers: [
              // Timestamp
              _cell(const Text("Timestamp", style: TextStyle(fontWeight: FontWeight.bold))),
              // Round
              _cell(const Text("Round", style: TextStyle(fontWeight: FontWeight.bold))),
              // Table
              _cell(const Text("Table", style: TextStyle(fontWeight: FontWeight.bold))),
              // Referee
              _cell(const Text("Referee", style: TextStyle(fontWeight: FontWeight.bold))),
              // Score
              _cell(const Text("Score", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _editTableRows(context),
          ),
        ),
      ),
    );
  }
}

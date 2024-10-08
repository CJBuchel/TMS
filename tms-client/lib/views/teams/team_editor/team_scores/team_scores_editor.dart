import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/widgets/dialogs/add_game_score_dialog.dart';
import 'package:tms/widgets/dialogs/edit_game_score_dialog.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';
import 'package:tms/widgets/team_widgets/team_score_sheet_tags.dart';

class TeamScoresEditor extends StatefulWidget {
  final String teamId;
  final List<TeamScoreSheet> teamScores;

  TeamScoresEditor({
    Key? key,
    required this.teamId,
    required this.teamScores,
  }) : super(key: key);

  @override
  _TeamScoresEditorState createState() => _TeamScoresEditorState();
}

class _TeamScoresEditorState extends State<TeamScoresEditor> {
  final ExpansionController _expansionController = ExpansionController();

  BaseTableCell _cell(Widget child) {
    return BaseTableCell(
      child: Center(child: child),
    );
  }

  List<EditTableRow> _editTableRows(BuildContext context) {
    widget.teamScores.sort((a, b) {
      DateTime other = tmsDateTimeToDateTime(b.scoreSheet.timestamp);
      return tmsDateTimeToDateTime(a.scoreSheet.timestamp).compareTo(other);
    });
    return widget.teamScores.map((score) {
      return EditTableRow(
        onDelete: () {
          ConfirmFutureDialog(
            style: ConfirmDialogStyle.error(
              title: 'Delete Score',
              message: const Text('Are you sure you want to delete this score?'),
            ),
            onStatusConfirmFuture: () {
              return Provider.of<GameScoringProvider>(context, listen: false).removeScoreSheet(score.scoreSheetId);
            },
          ).show(context);
        },
        onEdit: () => EditGameScoreDialog(score: score).show(context),
        cells: [
          // Timestamp
          _cell(Text(score.scoreSheet.timestamp.time?.toString() ?? '')),
          // Round
          _cell(Text(score.scoreSheet.round.toString())),
          // Table
          _cell(Text(score.scoreSheet.table)),
          // Referee
          _cell(Text(score.scoreSheet.referee)),
          // Score
          _cell(Text(
            score.scoreSheet.score.toString(),
            style: const TextStyle(color: Colors.green),
          )),
          // Tags
          _cell(TeamScoreSheetTags(gameScoreSheet: score.scoreSheet)),
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
              // Tags
              _cell(const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _editTableRows(context),
            onAdd: () => AddGameScoreDialog(teamId: widget.teamId).show(context),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/views/match_controller/match_stage/update_team_on_match.dart';
import 'package:tms/views/match_controller/match_stage/stage_table_data.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class StageTable extends StatelessWidget {
  final List<StageTableData> tableData;
  final List<String> stagedMatchNumbers;

  // editable team, table, and match data
  final ValueNotifier<String> selectedTable = ValueNotifier<String>("");
  final ValueNotifier<Team?> selectedTeam = ValueNotifier<Team?>(null);
  final ValueNotifier<String> selectedMatch = ValueNotifier<String>("");

  StageTable({
    Key? key,
    required this.tableData,
    required this.stagedMatchNumbers,
  }) : super(key: key);

  Widget _header(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // create rows
    List<EditTableRow> rows = [];

    for (var segment in tableData) {
      rows.add(
        EditTableRow(
          key: segment.table.table,
          onEdit: () {
            // preload selected data
            selectedTable.value = segment.table.table;
            selectedTeam.value = segment.team;
            selectedMatch.value = segment.matchNumber;

            ConfirmFutureDialog(
              style: ConfirmDialogStyle.info(
                title: "Update team ${segment.table.teamNumber} on match",
                message: UpdateTeamOnMatchWidget(
                  tableData: tableData,
                  stagedMatchNumbers: stagedMatchNumbers,
                  selectedTable: selectedTable,
                  selectedTeam: selectedTeam,
                  selectedMatch: selectedMatch,
                  filterAvailableData: false,
                ),
              ),
              onStatusConfirmFuture: () {
                if (selectedTeam.value == null || selectedTable.value.isEmpty || selectedMatch.value.isEmpty) {
                  return Future.value(HttpStatus.badRequest);
                } else {
                  GameMatchTable update = GameMatchTable(
                    table: selectedTable.value,
                    teamNumber: selectedTeam.value!.number,
                    scoreSubmitted: segment.table.scoreSubmitted,
                  );
                  return Provider.of<GameMatchProvider>(context, listen: false).updateTableOnMatch(
                    originTable: segment.table.table,
                    originMatchNumber: segment.matchNumber,
                    updatedTable: update,
                    updatedMatchNumber: selectedMatch.value,
                  );
                }
              },
            ).show(context);
          },
          onDelete: () {
            ConfirmFutureDialog(
              style: ConfirmDialogStyle.error(
                title: "Remove team ${segment.table.teamNumber} from match",
                message: Text(
                  "Are you sure you want to remove team '${segment.table.teamNumber}' from this match?",
                ),
              ),
              onStatusConfirmFuture: () {
                return Provider.of<GameMatchProvider>(context, listen: false).removeTableFromMatch(
                  segment.table.table,
                  segment.matchNumber,
                );
              },
            ).show(context);
          },
          cells: [
            BaseTableCell(
              child: Center(child: Text(segment.matchNumber)),
            ),
            BaseTableCell(
              child: Container(
                decoration: BoxDecoration(
                  color: segment.submittedPrior ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    segment.table.table,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            BaseTableCell(
              child: Center(child: Text(segment.table.teamNumber)),
            ),
            BaseTableCell(
              child: Center(
                child: Text(segment.team.name),
              ),
              flex: 2,
            )
          ],
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      );
    }

    return EditTable(
      headers: [
        BaseTableCell(
          child: _header("Match"),
        ),
        BaseTableCell(
          child: _header("Table"),
        ),
        BaseTableCell(
          child: _header("Team"),
        ),
        BaseTableCell(
          child: _header("Name"),
          flex: 2,
        ),
      ],
      rows: rows,
      onAdd: () {
        ConfirmFutureDialog(
            style: ConfirmDialogStyle.success(
              title: "Add team to match",
              message: UpdateTeamOnMatchWidget(
                tableData: tableData,
                stagedMatchNumbers: stagedMatchNumbers,
                selectedTable: selectedTable,
                selectedTeam: selectedTeam,
                selectedMatch: selectedMatch,
              ),
            ),
            onStatusConfirmFuture: () {
              if (selectedTeam.value == null || selectedTable.value.isEmpty || selectedMatch.value.isEmpty) {
                return Future.value(HttpStatus.badRequest);
              } else {
                return Provider.of<GameMatchProvider>(context, listen: false).addTableToMatch(
                  selectedTable.value,
                  selectedTeam.value!.number,
                  selectedMatch.value,
                );
              }
            }).show(context);
      },
    );
  }
}

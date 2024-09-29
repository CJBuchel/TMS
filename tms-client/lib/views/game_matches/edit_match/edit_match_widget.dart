import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/game_matches/edit_match/add_table_widget.dart';
import 'package:tms/views/game_matches/edit_match/edit_table_widget.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/edit_time.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class _AvailableData {
  final List<String> availableTables;
  final List<Team> availableTeams;

  _AvailableData({
    required this.availableTables,
    required this.availableTeams,
  });
}

class EditMatchWidget extends StatelessWidget {
  final GameMatch gameMatch;
  final TextEditingController matchNumberController;
  final ValueNotifier<TmsDateTime> startTime;
  final ValueNotifier<bool> completed;

  EditMatchWidget({
    required this.gameMatch,
    required this.matchNumberController,
    required this.startTime,
    required this.completed,
  });

  // editable team, table, submitted
  final ValueNotifier<String> _selectedTable = ValueNotifier<String>("");
  final ValueNotifier<Team> _selectedTeam = ValueNotifier<Team>(
    const Team(teamNumber: "", name: "", ranking: 0, affiliation: ""),
  );
  final ValueNotifier<bool> _selectedScoreSubmitted = ValueNotifier(false);

  // heh, padded cell
  BaseTableCell _paddedCell(Widget child) {
    return BaseTableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // set initial values
    matchNumberController.text = gameMatch.matchNumber;
    startTime.value = gameMatch.startTime;
    completed.value = gameMatch.completed;

    return Selector2<GameTableProvider, TeamsProvider, _AvailableData>(
      selector: (_, tableProvider, teamsProvider) {
        // get tables not referenced in the match
        List<String> availableTables = tableProvider.tableNames
            .where((table) => !gameMatch.gameMatchTables.any((data) => data.table == table))
            .map((table) => table)
            .toList();

        // get teams not referenced in the match
        List<Team> availableTeams = teamsProvider.teams
            .where((team) => !gameMatch.gameMatchTables.any((data) => data.teamNumber == team.teamNumber))
            .toList();

        return _AvailableData(
          availableTables: availableTables,
          availableTeams: availableTeams,
        );
      },
      builder: (context, data, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: matchNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Match Number",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: EditTimeWidget(
                label: "Start Time",
                initialTime: startTime.value,
                onChanged: (t) => startTime.value = t,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Completed: "),
                  LiveCheckbox(
                    defaultValue: completed.value,
                    onChanged: (v) => completed.value = v,
                  ),
                ],
              ),
            ),
            const Divider(),
            EditTable(
              onAdd: () {
                // initial values
                _selectedTable.value = data.availableTables.first;
                _selectedTeam.value = data.availableTeams.first;

                ConfirmFutureDialog(
                  onStatusConfirmFuture: () {
                    if (_selectedTeam.value.teamNumber.isEmpty || _selectedTable.value.isEmpty) {
                      return Future.value(HttpStatus.badRequest);
                    } else {
                      return Provider.of<GameMatchProvider>(context, listen: false).addTableToMatch(
                        _selectedTable.value,
                        _selectedTeam.value.teamNumber,
                        gameMatch.matchNumber,
                      );
                    }
                  },
                  style: ConfirmDialogStyle.success(
                    title: "Add team to match: ${gameMatch.matchNumber}",
                    message: AddTableWidget(
                      availableTables: data.availableTables,
                      availableTeams: data.availableTeams,
                      selectedTable: _selectedTable,
                      selectedTeam: _selectedTeam,
                    ),
                  ),
                ).show(context);
              },
              headers: [
                _paddedCell(const Text("Table", style: const TextStyle(fontWeight: FontWeight.bold))),
                _paddedCell(const Text("Team", style: const TextStyle(fontWeight: FontWeight.bold))),
                _paddedCell(const Text("Score", style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: gameMatch.gameMatchTables.map((gmt) {
                return EditTableRow(
                  onEdit: () {
                    _selectedTable.value = gmt.table;
                    _selectedTeam.value = Provider.of<TeamsProvider>(context, listen: false).getTeam(gmt.teamNumber);
                    _selectedScoreSubmitted.value = gmt.scoreSubmitted;

                    ConfirmFutureDialog(
                      onStatusConfirmFuture: () {
                        if (_selectedTeam.value.teamNumber.isEmpty || _selectedTable.value.isEmpty) {
                          return Future.value(HttpStatus.badRequest);
                        } else {
                          return Provider.of<GameMatchProvider>(context, listen: false).updateTableOnMatch(
                            originTable: gmt.table,
                            originMatchNumber: gameMatch.matchNumber,
                            updatedTable: GameMatchTable(
                              table: _selectedTable.value,
                              teamNumber: _selectedTeam.value.teamNumber,
                              scoreSubmitted: _selectedScoreSubmitted.value,
                            ),
                          );
                        }
                      },
                      style: ConfirmDialogStyle.warn(
                        title: "Update team ${gmt.teamNumber} on table ${gmt.table}",
                        message: EditTableWidget(
                          availableTables: data.availableTables,
                          availableTeams: data.availableTeams,
                          selectedTable: _selectedTable,
                          selectedTeam: _selectedTeam,
                          scoreSubmitted: _selectedScoreSubmitted,
                        ),
                      ),
                    ).show(context);
                  },
                  onDelete: () {
                    ConfirmFutureDialog(
                      style: ConfirmDialogStyle.error(
                        title: "Delete team ${gmt.teamNumber} from match",
                        message: const Text("Are you sure you want to delete this team from the match?"),
                      ),
                      onStatusConfirmFuture: () {
                        return Provider.of<GameMatchProvider>(context, listen: false).removeTableFromMatch(
                          gmt.table,
                          gameMatch.matchNumber,
                        );
                      },
                    ).show(context);
                  },
                  cells: [
                    _paddedCell(Text(gmt.table)),
                    _paddedCell(Text(gmt.teamNumber)),
                    _paddedCell(Text(gmt.scoreSubmitted.toString())),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:collection/collection.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class RescheduleButton extends StatelessWidget {
  final GameMatch match;

  RescheduleButton({
    required this.match,
  });

  final ValueNotifier<String?> _selectedTeamNumber = ValueNotifier(null);
  final ValueNotifier<GameMatch?> _selectedMatch = ValueNotifier(null);
  final ValueNotifier<String?> _selectedTable = ValueNotifier(null);

  Widget _buildDialogMessage() {
    return Selector2<GameMatchProvider, GameTableProvider, ({List<GameMatch> matches, List<String> tables})>(
      selector: (context, matchProvider, tableProvider) {
        // get matches which are not completed
        List<GameMatch> matches = matchProvider.matches.where((m) => !m.completed).toList();
        List<String> tables = tableProvider.tables.map((table) => table.tableName).toList();
        return (matches: matches, tables: tables);
      },
      builder: (context, data, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // dropdown for teams
            DropdownSearch<String>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
              ),
              items: match.gameMatchTables.map((table) => table.teamNumber).toList(),
              itemAsString: (team) => "${team}",
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                  labelText: "Team",
                  hintText: "Select Team",
                ),
              ),
              onChanged: (value) => _selectedTeamNumber.value = value,
            ),

            // down arrow
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Icon(
                Icons.arrow_downward,
              ),
            ),

            // dropdown for match number
            DropdownSearch<GameMatch>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
              ),
              items: data.matches,
              itemAsString: (match) => "${match.matchNumber} - ${match.startTime.toString()}",
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                  labelText: "Match",
                  hintText: "Select Match",
                ),
              ),
              onChanged: (value) => _selectedMatch.value = value,
            ),

            // divider
            const SizedBox(height: 20),

            // dropdown for table
            ValueListenableBuilder(
              valueListenable: _selectedMatch,
              builder: (context, sm, _) {
                return DropdownSearch<String?>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                  ),
                  items: data.tables.where((t) {
                    List<String> smTables = sm?.gameMatchTables.map((table) => table.table).toList() ?? [];
                    return !smTables.contains(t);
                  }).toList(),
                  itemAsString: (table) => "${table}",
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                      labelText: "Table",
                      hintText: "Select Table",
                    ),
                  ),
                  onChanged: (value) => _selectedTable.value = value,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    ConfirmFutureDialog(
      style: DialogStyle.warn(
        title: 'Reschedule Team',
        message: _buildDialogMessage(),
      ),
      onStatusConfirmFuture: () {
        if (_selectedTeamNumber.value == null || _selectedMatch.value == null || _selectedTable.value == null) {
          return Future.value(HttpStatus.badRequest);
        }

        // get origin table
        String? originTable = match.gameMatchTables.firstWhereOrNull((t) {
          return t.teamNumber == _selectedTeamNumber.value;
        })?.table;

        if (originTable == null) {
          return Future.value(HttpStatus.badRequest);
        }

        return Provider.of<GameMatchProvider>(context, listen: false).updateTableOnMatch(
          originTable: originTable,
          originMatchNumber: match.matchNumber,
          updatedMatchNumber: _selectedMatch.value!.matchNumber,
          updatedTable: GameMatchTable(
            table: _selectedTable.value!,
            teamNumber: _selectedTeamNumber.value!,
            scoreSubmitted: false,
          ),
        );
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.purple),
        overlayColor: WidgetStateProperty.all(Colors.purple[400]),
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: () => _showRescheduleDialog(context),
      icon: const Icon(Icons.schedule, color: Colors.black),
    );
  }
}

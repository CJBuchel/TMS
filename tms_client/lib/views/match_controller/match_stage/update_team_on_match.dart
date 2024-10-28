import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/views/match_controller/match_stage/stage_table_data.dart';

class _AvailableData {
  final List<String> availableTables;
  final List<Team> availableTeams;

  _AvailableData({
    required this.availableTables,
    required this.availableTeams,
  });
}

class UpdateTeamOnMatchWidget extends StatelessWidget {
  final bool isEditing;

  final List<StageTableData> tableData;
  final List<String> stagedMatchNumbers;

  final ValueNotifier<String> selectedTable;
  final ValueNotifier<Team?> selectedTeam;
  final ValueNotifier<String> selectedMatch;

  UpdateTeamOnMatchWidget({
    Key? key,
    required this.isEditing,
    required this.tableData,
    required this.stagedMatchNumbers,
    required this.selectedTable,
    required this.selectedTeam,
    required this.selectedMatch,
  }) : super(key: key);

  Widget _selectAvailableTeamWidget(List<Team> availableTeams) {
    if (availableTeams.isEmpty) {
      return const SizedBox();
    } else if (selectedTeam.value == null || !isEditing) {
      selectedTeam.value = availableTeams.first;
    }

    return DropdownSearch<Team>(
      popupProps: const PopupProps.menu(
        showSearchBox: true,
      ),
      items: availableTeams,
      itemAsString: (team) => "${team.teamNumber} - ${team.name}",
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
          labelText: "Team",
          hintText: "Select Team",
        ),
      ),
      onChanged: (value) {
        if (value != null) selectedTeam.value = value;
      },
      selectedItem: selectedTeam.value,
    );
  }

  Widget _selectAvailableTableWidget(List<String> availableTables) {
    if (availableTables.isEmpty) {
      return const SizedBox();
    } else if (selectedTable.value.isEmpty || !isEditing) {
      selectedTable.value = availableTables.first;
    }

    return DropdownSearch<String>(
      popupProps: const PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: true,
      ),
      items: availableTables,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
          labelText: "On Table",
          hintText: "Select Table",
        ),
      ),
      onChanged: (value) {
        if (value != null) selectedTable.value = value;
      },
      selectedItem: selectedTable.value,
    );
  }

  Widget _selectAvailableMatchesWidget(List<String> availableMatchNumbers) {
    if (availableMatchNumbers.isEmpty) {
      return const SizedBox();
    } else if (selectedMatch.value.isEmpty || !isEditing) {
      selectedMatch.value = availableMatchNumbers.first;
    }

    return DropdownSearch<String>(
      popupProps: const PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: true,
      ),
      items: availableMatchNumbers,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
          labelText: "In Match",
          hintText: "Select Match",
        ),
      ),
      onChanged: (value) {
        if (value != null) selectedMatch.value = value;
      },
      selectedItem: selectedMatch.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<GameTableProvider, TeamsProvider, _AvailableData>(
      selector: (context, tableProvider, teamProvider) {
        // get tables not referenced in the tableData list
        List<String> availableTables = tableProvider.tableNames
            .where((table) => !tableData.any((data) => data.table.table == table))
            .map((table) => table)
            .toList();
        // get teams not referenced in the tableData list
        List<Team> availableTeams = sortTeamsByNumber(teamProvider.teams
            .where((team) => !tableData.any((data) => data.team.teamNumber == team.teamNumber))
            .toList());

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
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: _selectAvailableTeamWidget(data.availableTeams),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: _selectAvailableTableWidget(data.availableTables),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: _selectAvailableMatchesWidget(stagedMatchNumbers),
            ),
          ],
        );
      },
    );
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class AddTableWidget extends StatelessWidget {
  final List<String> availableTables;
  final List<Team> availableTeams;
  final ValueNotifier<String> selectedTable;
  final ValueNotifier<Team> selectedTeam;

  AddTableWidget({
    required this.availableTables,
    required this.availableTeams,
    required this.selectedTable,
    required this.selectedTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // team
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: DropdownSearch<Team>(
            popupProps: const PopupProps.menu(
              showSearchBox: true,
            ),
            items: availableTeams,
            itemAsString: (t) => "${t.teamNumber} - ${t.name}",
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                labelText: "Team",
                hintText: "Select Team",
              ),
            ),
            onChanged: (v) {
              if (v != null) selectedTeam.value = v;
            },
            selectedItem: selectedTeam.value,
          ),
        ),
        // table
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: DropdownSearch<String>(
            popupProps: const PopupProps.menu(
              showSearchBox: true,
            ),
            items: availableTables,
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                labelText: "Table",
                hintText: "Select Table",
              ),
            ),
            onChanged: (v) {
              if (v != null) selectedTable.value = v;
            },
            selectedItem: selectedTable.value,
          ),
        ),
      ],
    );
  }
}

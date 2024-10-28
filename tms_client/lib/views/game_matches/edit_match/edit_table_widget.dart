import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';

class EditTableWidget extends StatelessWidget {
  final List<String> availableTables;
  final List<Team> availableTeams;
  final ValueNotifier<String> selectedTable;
  final ValueNotifier<Team> selectedTeam;
  final ValueNotifier<bool> scoreSubmitted;

  EditTableWidget({
    required this.availableTables,
    required this.availableTeams,
    required this.selectedTable,
    required this.selectedTeam,
    required this.scoreSubmitted,
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
        // submitted
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Score Submitted: "),
              LiveCheckbox(
                defaultValue: scoreSubmitted.value,
                onChanged: (v) => scoreSubmitted.value = v,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

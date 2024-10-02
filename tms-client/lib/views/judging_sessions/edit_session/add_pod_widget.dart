import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class AddPodWidget extends StatelessWidget {
  final List<String> availablePods;
  final List<Team> availableTeams;
  final ValueNotifier<String> selectedPod;
  final ValueNotifier<Team> selectedTeam;

  AddPodWidget({
    required this.availablePods,
    required this.availableTeams,
    required this.selectedPod,
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
        // pod
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: DropdownSearch<String>(
            popupProps: const PopupProps.menu(
              showSearchBox: true,
            ),
            items: availablePods,
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                labelText: "Pod",
                hintText: "Select Pod",
              ),
            ),
            onChanged: (v) {
              if (v != null) selectedPod.value = v;
            },
            selectedItem: selectedPod.value,
          ),
        ),
      ],
    );
  }
}

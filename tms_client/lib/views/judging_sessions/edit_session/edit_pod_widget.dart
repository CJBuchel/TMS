import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';

class EditPodWidget extends StatelessWidget {
  final List<String> availablePods;
  final List<Team> availableTeams;
  final ValueNotifier<String> selectedPod;
  final ValueNotifier<Team> selectedTeam;
  final ValueNotifier<bool> coreValuesSubmitted;
  final ValueNotifier<bool> innovationSubmitted;
  final ValueNotifier<bool> robotDesignSubmitted;

  EditPodWidget({
    required this.availablePods,
    required this.availableTeams,
    required this.selectedPod,
    required this.selectedTeam,
    required this.coreValuesSubmitted,
    required this.innovationSubmitted,
    required this.robotDesignSubmitted,
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
        // core values
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Core Values"),
              LiveCheckbox(
                defaultValue: coreValuesSubmitted.value,
                onChanged: (v) {
                  coreValuesSubmitted.value = v;
                },
              ),
            ],
          ),
        ),
        // innovation
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Innovation"),
              LiveCheckbox(
                defaultValue: innovationSubmitted.value,
                onChanged: (v) {
                  innovationSubmitted.value = v;
                },
              ),
            ],
          ),
        ),
        // robot design
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Robot Design"),
              LiveCheckbox(
                defaultValue: robotDesignSubmitted.value,
                onChanged: (v) {
                  robotDesignSubmitted.value = v;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

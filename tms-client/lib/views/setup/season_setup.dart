import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class _BlueprintData {
  final BlueprintType bpType;
  final String selectedBlueprint;
  final List<String> blueprintTitles;

  _BlueprintData({
    required this.bpType,
    required this.selectedBlueprint,
    required this.blueprintTitles,
  });
}

class SeasonSetup extends StatelessWidget {
  SeasonSetup({Key? key}) : super(key: key);

  final ValueNotifier<List<String>> availableSeasons = ValueNotifier<List<String>>([]);
  final ValueNotifier<String> selectedBlueprint = ValueNotifier<String>("Agnostic");

  Widget seasonDropdown() {
    return ValueListenableBuilder(
      valueListenable: selectedBlueprint,
      builder: (context, value, _) {
        return DropdownButton<String>(
          value: value,
          items: [
            const DropdownMenuItem<String>(
              value: "Agnostic",
              child: Text("Agnostic"),
            ),
            ...availableSeasons.value.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ],
          onChanged: (String? value) {
            selectedBlueprint.value = value!;
          },
        );
      },
    );
  }

  void showSnackBar(BuildContext context, int status) {
    SnackBarDialog.fromStatus(message: "Season set ${selectedBlueprint.value}", status: status).show(context);
  }

  Widget input(BuildContext context, TournamentConfigProvider config) {
    return InputSetter(
      label: "Select Blueprint",
      input: seasonDropdown(),
      onSet: () async {
        if (selectedBlueprint.value == "Agnostic") {
          TmsLogger().i("Setting season to Agnostic");
          await config.setSeasonAgnostic().then((status) => showSnackBar(context, status));
        } else {
          TmsLogger().i("Setting season to ${selectedBlueprint.value}");
          await config.setSeason(selectedBlueprint.value).then((status) => showSnackBar(context, status));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    availableSeasons.value = Provider.of<TournamentBlueprintProvider>(context, listen: false).blueprintTitles;

    return EchoTreeLifetime(
      trees: [":tournament:blueprint", ":tournament:config"],
      child: Selector<TournamentBlueprintProvider, _BlueprintData>(
        selector: (context, provider) {
          return _BlueprintData(
            bpType: provider.blueprintType,
            selectedBlueprint: provider.season,
            blueprintTitles: provider.blueprintTitles,
          );
        },
        builder: (context, blueprints, _) {
          availableSeasons.value = blueprints.blueprintTitles;
          if (blueprints.bpType == BlueprintType.agnostic) {
            selectedBlueprint.value = "Agnostic";
          } else {
            if (availableSeasons.value.contains(blueprints.selectedBlueprint)) {
              selectedBlueprint.value = blueprints.selectedBlueprint;
            } else {
              selectedBlueprint.value = "Agnostic";
            }
          }
          return Consumer<TournamentConfigProvider>(
            builder: (context, config, _) {
              return input(context, config);
            },
          );
        },
      ),
    );
  }
}

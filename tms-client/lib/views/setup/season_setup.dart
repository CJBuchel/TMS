import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

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
    availableSeasons.value = Provider.of<TournamentBlueprintProvider>(context).blueprintTitles;

    return EchoTreeLifetime(
      trees: [":tournament:blueprint", ":tournament:config"],
      child: Selector<TournamentBlueprintProvider, List<String>>(
        selector: (context, provider) => provider.blueprintTitles,
        builder: (context, blueprints, _) {
          availableSeasons.value = blueprints;
          return Consumer<TournamentConfigProvider>(
            builder: (context, config, _) {
              // check season type
              if (config.blueprintType == BlueprintType.agnostic) {
                selectedBlueprint.value = "Agnostic";
              } else {
                if (availableSeasons.value.contains(config.season)) {
                  selectedBlueprint.value = config.season;
                } else {
                  selectedBlueprint.value = "Agnostic";
                }
              }

              return input(context, config);
            },
          );
        },
      ),
    );
  }
}

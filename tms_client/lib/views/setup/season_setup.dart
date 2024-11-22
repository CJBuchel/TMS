import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/fll_infra/fll_blueprint_map.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

const String AGNOSTIC = "Agnostic";

class SeasonSetup extends StatelessWidget {
  SeasonSetup({Key? key}) : super(key: key);
  final ValueNotifier<String> selectedSeason = ValueNotifier<String>(AGNOSTIC);

  Widget seasonDropdown(String season) {
    return ValueListenableBuilder(
      valueListenable: selectedSeason,
      builder: (context, v, _) {
        return DropdownButton<String>(
          value: v,
          items: [
            const DropdownMenuItem<String>(
              value: AGNOSTIC,
              child: Text(AGNOSTIC),
            ),
            ...FllBlueprintMap.getSeasons().map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ],
          onChanged: (String? value) {
            if (value != null) selectedSeason.value = value;
          },
        );
      },
    );
  }

  void showSnackBar(BuildContext context, int status) {
    SnackBarDialog.fromStatus(message: "Season set ${selectedSeason.value}", status: status).show(context);
  }

  Widget input(BuildContext context, TournamentConfigProvider config) {
    return InputSetter(
      label: "Select Blueprint",
      input: seasonDropdown(config.season),
      onSet: () async {
        if (selectedSeason.value == AGNOSTIC) {
          TmsLogger().i("Setting season to Agnostic");
          await config.setSeasonAgnostic().then((status) => showSnackBar(context, status));
        } else {
          TmsLogger().i("Setting season to ${selectedSeason.value}");
          await config.setSeason(selectedSeason.value).then((status) => showSnackBar(context, status));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    return Consumer<TournamentConfigProvider>(
      builder: (context, config, _) {
        if (config.blueprintType == BlueprintType.agnostic) {
          selectedSeason.value = AGNOSTIC;
        } else {
          if (FllBlueprintMap.getSeasons().contains(config.season)) {
            selectedSeason.value = config.season;
          } else {
            selectedSeason.value = AGNOSTIC;
          }
        }
        return input(context, config);
      },
    );
  }
}

import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/setup/input_setter.dart';

class SeasonSetup extends StatelessWidget {
  SeasonSetup({Key? key}) : super(key: key);

  final ValueNotifier<String> selectedBlueprint = ValueNotifier<String>("Agnostic");

  Widget seasonDropdown(TournamentBlueprintProvider provider) {
    List<String> titles = provider.blueprintTitles;
    titles.insert(0, "Agnostic");

    return ValueListenableBuilder(
      valueListenable: selectedBlueprint,
      builder: (context, value, _) {
        return DropdownButton<String>(
          value: value,
          items: titles.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            selectedBlueprint.value = value!;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":tournament:blueprint"],
      child: Consumer<TournamentBlueprintProvider>(
        builder: (context, provider, _) {
          return InputSetter(
            label: "Select Blueprint",
            input: seasonDropdown(provider),
            onSet: () async {
              TmsLogger().i("Length: ${provider.blueprints.length}");
              TmsLogger().i(provider.blueprints[0].toJsonString());
            },
          );
        },
      ),
    );
  }
}

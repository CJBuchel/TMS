import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/views/setup/input_setter.dart';

class BlueprintSetup extends StatelessWidget {
  BlueprintSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":tournament:blueprint"],
      child: Consumer<TournamentBlueprintProvider>(
        builder: (context, provider, _) {
          return InputSetter(
            label: "Upload Season Blueprint (optional):",
            input: ElevatedButton(
              onPressed: () async {
                // await provider.selectBlueprint();
              },
              child: Text("Select Blueprint (JSON)"),
            ),
            onSet: () async {},
          );
        },
      ),
    );
  }
}

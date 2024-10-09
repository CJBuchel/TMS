import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class BlueprintSetup extends StatelessWidget {
  BlueprintSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentBlueprintProvider>(
      builder: (context, provider, _) {
        return InputSetter(
          label: "Upload Season Blueprint (optional):",
          input: ElevatedButton(
            onPressed: () async {
              await provider.selectBlueprint();
            },
            child: Text(provider.result == null ? "Select Blueprint (JSON)" : provider.result?.files.first.name ?? ""),
          ),
          onSet: () async {
            await provider.uploadBlueprint().then((res) {
              SnackBarDialog.fromStatus(message: "Upload Blueprint", status: res).show(context);
            });
          },
        );
      },
    );
  }
}

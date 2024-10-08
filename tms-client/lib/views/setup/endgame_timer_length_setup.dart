import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class EndgameTimerLengthSetup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentConfigProvider>(
      builder: (context, provider, child) {
        _controller.text = provider.endGameTimerLength.toString();
        return InputSetter(
          label: "Set endgame length:",
          onSet: () async {
            await provider.setEndgameTimerLength(int.parse(_controller.text)).then((res) {
              SnackBarDialog.fromStatus(message: "Set Endgame Length", status: res).show(context);
            });
          },
          input: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Endgame Length (seconds)",
            ),
          ),
        );
      },
    );
  }
}

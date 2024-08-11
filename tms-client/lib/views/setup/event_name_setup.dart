import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class EventNameSetup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":tournament:config"],
      child: Consumer<TournamentConfigProvider>(
        builder: (context, provider, child) {
          _controller.text = provider.eventName;
          return InputSetter(
            label: "Set event name:",
            onSet: () async {
              await provider.setEventName(_controller.text).then((res) {
                SnackBarDialog.fromStatus(message: "Set Event Name", status: res).show(context);
              });
            },
            input: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Event Name",
              ),
            ),
          );
        },
      ),
    );
  }
}

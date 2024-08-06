import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/event_config_provider.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class AdminPasswordSetup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<EventConfigProvider>(
      builder: (context, provider, _) {
        return InputSetter(
          label: "Set admin password:",
          onSet: () async {
            await provider.setAdminPassword(_controller.text).then((res) {
              SnackBarDialog.fromStatus(message: "Set Admin Password", status: res).show(context);
            });
          },
          input: TextField(
            controller: _controller,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Admin Password",
            ),
          ),
        );
      },
    );
  }
}

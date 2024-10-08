import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class BackupIntervalSetup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentConfigProvider>(
      builder: (context, provider, _) {
        _controller.text = provider.backupInterval.toString();
        return InputSetter(
          label: "Set backup interval:",
          onSet: () async {
            await provider.setBackupInterval(int.parse(_controller.text)).then((res) {
              SnackBarDialog.fromStatus(message: "Set Backup Interval", status: res).show(context);
            });
          },
          input: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Backup Interval (minutes)",
            ),
          ),
        );
      },
    );
  }
}

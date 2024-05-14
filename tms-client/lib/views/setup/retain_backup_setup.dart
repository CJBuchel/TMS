import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/event_config_provider.dart';
import 'package:tms/views/setup/input_setter.dart';

class BackupRetentionSetup extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    EchoTreeClient().subscribe([":tournament:config"]);
    return EchoTreeLifetime(
      trees: [":tournament:config"],
      child: Column(
        children: [
          Consumer<EventConfigProvider>(
            builder: (context, provider, child) {
              _controller.text = provider.retainBackups.toString();
              return InputSetter(
                label: "Set number of backups to retain:",
                onSet: () async {
                  await provider.setRetainBackups(int.parse(_controller.text));
                },
                input: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Backup Retention",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
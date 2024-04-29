import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/event_config_provider.dart';
import 'package:tms/views/setup/input_setter.dart';

class EventNameSetup extends StatelessWidget {
  final TextEditingController _eventNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    EchoTreeClient().subscribe([":tournament:config"]);
    return EchoTreeLifetime(
      trees: [":tournament:config"],
      child: Column(
        children: [
          Consumer<EventConfigProvider>(
            builder: (context, provider, child) {
              _eventNameController.text = provider.eventName;
              return InputSetter(
                label: "Upload Schedule:",
                onSet: () async {
                  await provider.setEventName(_eventNameController.text);
                },
                input: TextField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Event Name",
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

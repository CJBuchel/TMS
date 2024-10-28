import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';

class IconTooltipIntegrityCheck extends StatelessWidget {
  final List<TournamentIntegrityMessage> messages;

  const IconTooltipIntegrityCheck({
    Key? key,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Icon(
        Icons.check,
        color: Colors.green,
      );
    } else {
      // check if any messages are errors
      bool hasError = false;
      List<String> integrityMessages = [];
      for (var m in messages) {
        m.integrityCode.when(
          error: (e) {
            hasError = true;
            integrityMessages.add(m.message);
          },
          warning: (w) {
            integrityMessages.add(m.message);
          },
        );
      }

      return Tooltip(
        message: integrityMessages.join('\n'),
        child: Icon(
          Icons.error,
          color: hasError ? Colors.red : Colors.orange,
        ),
      );
    }
  }
}

import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":tournament:integrity_messages",
      ],
      child: Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
        selector: (context, provider) => provider.messages,
        builder: (context, messages, _) {
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages[index].message),
              );
            },
          );
        },
      ),
    );
  }
}

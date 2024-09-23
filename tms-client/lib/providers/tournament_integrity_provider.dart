import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';

class TournamentIntegrityProvider extends EchoTreeProvider<String, TournamentIntegrityMessage> {
  TournamentIntegrityProvider()
      : super(
          tree: ":tournament:integrity_messages",
          fromJsonString: (json) => TournamentIntegrityMessage.fromJsonString(json: json),
        );

  List<TournamentIntegrityMessage> get messages => this.items.values.toList();
}

import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';

class TournamentIntegrityProvider extends EchoTreeProvider<String, TournamentIntegrityMessage> {
  TournamentIntegrityProvider()
      : super(
          tree: ":tournament:integrity_messages",
          fromJsonString: (json) => TournamentIntegrityMessage.fromJsonString(json: json),
        );

  List<TournamentIntegrityMessage> get messages => this.items.values.toList();

  List<TournamentIntegrityMessage> get teamMessages {
    return this.messages.where((element) => element.teamNumber != null).toList();
  }

  List<TournamentIntegrityMessage> get matchMessages {
    return this.messages.where((element) => element.matchNumber != null).toList();
  }

  List<TournamentIntegrityMessage> get sessionMessages {
    return this.messages.where((element) => element.sessionNumber != null).toList();
  }

  List<TournamentIntegrityMessage> getTeamMessages(String teamNumber) {
    return this.teamMessages.where((element) => element.teamNumber == teamNumber).toList();
  }

  List<TournamentIntegrityMessage> getMatchMessages(String matchNumber) {
    return this.matchMessages.where((element) => element.matchNumber == matchNumber).toList();
  }

  List<TournamentIntegrityMessage> getSessionMessages(String sessionNumber) {
    return this.sessionMessages.where((element) => element.sessionNumber == sessionNumber).toList();
  }
}

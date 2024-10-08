import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/utils/sorter_util.dart';

class TournamentIntegrityProvider extends EchoTreeProvider<String, TournamentIntegrityMessage> {
  TournamentIntegrityProvider()
      : super(
          tree: ":tournament:integrity_messages",
          fromJsonString: (json) => TournamentIntegrityMessage.fromJsonString(json: json),
        );

  List<TournamentIntegrityMessage> get messagesSortedByCode {
    List<TournamentIntegrityMessage> sortedMessages = this.items.values.toList();
    sortedMessages.sort((a, b) {
      // Prioritize errors over warnings
      bool aIsError = a.integrityCode.when(error: (e) => true, warning: (w) => false);
      bool bIsError = b.integrityCode.when(error: (e) => true, warning: (w) => false);

      if (aIsError && !bIsError) {
        return -1;
      } else if (!aIsError && bIsError) {
        return 1;
      }

      var aCode = extractNumberFromString(a.integrityCode.getStringifiedCode());
      var bCode = extractNumberFromString(b.integrityCode.getStringifiedCode());
      return aCode.compareTo(bCode);
    });

    return sortedMessages;
  }

  List<TournamentIntegrityMessage> get messages => messagesSortedByCode;

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

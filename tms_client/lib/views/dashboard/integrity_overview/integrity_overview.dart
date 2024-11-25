import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/dashboard/integrity_overview/integrity_message_tile.dart';

class IntegrityOverview extends StatelessWidget {
  const IntegrityOverview({Key? key}) : super(key: key);

  List<List<TournamentIntegrityMessage>> _splitMessagesByCode(List<TournamentIntegrityMessage> messages) {
    Map<String, List<TournamentIntegrityMessage>> groupedMessages = {};

    for (var message in messages) {
      String code = message.integrityCode.getStringifiedCode();
      if (!groupedMessages.containsKey(code)) {
        groupedMessages[code] = [];
      }
      groupedMessages[code]?.add(message);
    }

    return groupedMessages.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
      selector: (_, provider) => provider.messages,
      builder: (context, integrityMessages, _) {
        Color mainColor = Colors.grey;

        if (integrityMessages.any((m) => m.integrityCode.when(error: (e) => true, warning: (w) => false))) {
          mainColor = Colors.red;
        } else if (integrityMessages.any((m) => m.integrityCode.when(error: (e) => false, warning: (w) => true))) {
          mainColor = Colors.orange;
        }

        final groupedMessages = _splitMessagesByCode(integrityMessages);

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: mainColor),
              left: BorderSide(color: mainColor),
              right: BorderSide(color: mainColor),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Integrity Messages",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: groupedMessages.map((mGroup) {
                      return Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Theme.of(context).cardColor
                              : lighten(Theme.of(context).cardColor, 0.05),
                          border: Border.all(color: Colors.black),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: IntegrityMessageTile(messages: mGroup),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

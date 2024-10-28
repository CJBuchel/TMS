import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';

class IntegrityOverview extends StatelessWidget {
  const IntegrityOverview({Key? key}) : super(key: key);

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
                    children: integrityMessages.map((m) {
                      return Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Theme.of(context).cardColor
                              : lighten(Theme.of(context).cardColor, 0.05),
                          border: Border.all(color: Colors.black),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: ListTile(
                          leading: IconTooltipIntegrityCheck(messages: [m]),
                          title: Text(
                            m.integrityCode.getMessage(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              // code
                              Text(
                                m.integrityCode.getStringifiedCode(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: m.integrityCode.when(
                                    error: (_) => Colors.red,
                                    warning: (_) => Colors.orange,
                                  ),
                                ),
                              ),
                              // team (if applicable)
                              if (m.teamNumber != null) ...[
                                const SizedBox(width: 10),
                                Text(
                                  "Team ${m.teamNumber}",
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              // match (if applicable)
                              if (m.matchNumber != null) ...[
                                const SizedBox(width: 10),
                                Text(
                                  "Match ${m.matchNumber}",
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              // session (if applicable)
                              if (m.sessionNumber != null) ...[
                                const SizedBox(width: 10),
                                Text(
                                  "Session ${m.sessionNumber}",
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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

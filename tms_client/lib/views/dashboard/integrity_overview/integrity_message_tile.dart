import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';

class IntegrityMessageTile extends StatelessWidget {
  final List<TournamentIntegrityMessage> messages;
  final ExpansionController _expansionController = ExpansionController(isExpanded: false);

  IntegrityMessageTile({
    Key? key,
    required this.messages,
  }) : super(key: key);

  Widget _tile(BuildContext context, TournamentIntegrityMessage m) {
    return ListTile(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (messages.length > 1) {
      return Badge.count(
        count: messages.length,
        backgroundColor: Colors.red,
        child: ExpandableTile(
          controller: _expansionController,
          header: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                IconTooltipIntegrityCheck(messages: messages),
                const SizedBox(width: 10),
                // code
                Text(
                  messages.first.integrityCode.getStringifiedCode(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: messages.first.integrityCode.when(
                      error: (_) => Colors.red,
                      warning: (_) => Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  messages.first.integrityCode.getMessage(),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                ValueListenableBuilder(
                  valueListenable: _expansionController,
                  builder: (context, isExpanded, _) {
                    return Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    );
                  },
                ),
              ],
            ),
          ),
          body: Column(
            children: messages.map((m) => _tile(context, m)).toList(),
          ),
        ),
      );
    } else if (messages.isNotEmpty) {
      return _tile(context, messages.first);
    } else {
      return const SizedBox();
    }
  }
}

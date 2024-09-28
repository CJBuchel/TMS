import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/game_matches/on_delete_match.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class GameMatches extends StatelessWidget {
  Widget _gameMatchTables(
    BuildContext context,
    List<GameMatchTable> tables, {
    Color? backgroundColor,
    Color? submittedColor,
    bool isMatchComplete = false,
  }) {
    return Row(
      children: tables.map((t) {
        Color? c = t.scoreSubmitted
            ? submittedColor
            : isMatchComplete
                ? Colors.red
                : backgroundColor;
        return Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: c,
            ),
            child: Column(
              children: [
                Text(
                  t.table,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  t.teamNumber,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<EditTableRow> _rows(BuildContext context, List<GameMatch> gameMatches) {
    return gameMatches.asMap().entries.map((entry) {
      int i = entry.key;
      GameMatch m = entry.value;
      Color c = i.isEven ? lighten(Theme.of(context).cardColor, 0.05) : lighten(Theme.of(context).cardColor, 0.1);
      Color esb = Colors.green[500] ?? Colors.green;
      Color osb = Colors.green[300] ?? Colors.green;
      Color sb = i.isEven ? esb : osb;
      return EditTableRow(
        onDelete: () => OnDeleteGameMatch(matchNumber: m.matchNumber).call(context),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        cells: [
          BaseTableCell(
            child: Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
              selector: (context, provider) => provider.getMatchMessages(m.matchNumber),
              builder: (context, integrityMessages, _) {
                return Center(child: IconTooltipIntegrityCheck(messages: integrityMessages));
              },
            ),
            flex: 1,
          ),
          BaseTableCell(
            child: Center(child: Text(m.matchNumber)),
            flex: 1,
          ),
          BaseTableCell(
            child: Center(child: Text(m.startTime.toString())),
            flex: 1,
          ),
          BaseTableCell(
            child: _gameMatchTables(
              context,
              m.gameMatchTables,
              backgroundColor: c,
              submittedColor: sb,
              isMatchComplete: m.completed,
            ),
            flex: 4,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":robot_game:matches",
        ":teams",
        ":tournament:integrity_messages",
      ],
      child: Selector<GameMatchProvider, List<GameMatch>>(
        selector: (context, provider) => provider.matches,
        builder: (context, gameMatches, _) {
          return Column(
            children: [
              Expanded(
                child: EditTable(
                  headers: [
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Integrity", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 1,
                    ),
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Match", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 1,
                    ),
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 1,
                    ),
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Tables", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 4,
                    ),
                  ],
                  rows: _rows(context, gameMatches),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

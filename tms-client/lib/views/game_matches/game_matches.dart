import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_duration.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/game_matches/matches_info_banner.dart';
import 'package:tms/views/game_matches/on_add_match.dart';
import 'package:tms/views/game_matches/on_delete_match.dart';
import 'package:tms/views/game_matches/edit_match/edit_match_widget.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
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

  // selected match variables
  final TextEditingController _selectedMatchNumberController = TextEditingController();
  final ValueNotifier<TmsDateTime> _selectedStartTime = ValueNotifier(TmsDateTime());
  final ValueNotifier<bool> _selectedCompleted = ValueNotifier(false);

  List<EditTableRow> _rows(BuildContext context, List<GameMatch> gameMatches) {
    return gameMatches.asMap().entries.map((entry) {
      int i = entry.key;
      GameMatch m = entry.value;
      Color c = i.isEven ? Theme.of(context).cardColor : lighten(Theme.of(context).cardColor, 0.05);
      Color esb = Colors.green[500] ?? Colors.green;
      Color osb = Colors.green[300] ?? Colors.green;
      Color sb = i.isEven ? esb : osb;
      return EditTableRow(
        onEdit: () => ConfirmFutureDialog(
          onStatusConfirmFuture: () {
            return Provider.of<GameMatchProvider>(context, listen: false).insertGameMatch(
              m.matchNumber,
              GameMatch(
                matchNumber: _selectedMatchNumberController.text,
                startTime: _selectedStartTime.value,
                endTime: TmsDateTime(time: _selectedStartTime.value.time).addDuration(
                  duration: TmsDuration(minutes: 4),
                ),
                gameMatchTables: m.gameMatchTables,
                completed: _selectedCompleted.value,
                category: m.category,
              ),
            );
          },
          style: ConfirmDialogStyle.warn(
            title: "Edit Match: ${m.matchNumber}",
            message: Selector<GameMatchProvider, GameMatch?>(
              selector: (context, provider) => provider.getMatchByMatchNumber(m.matchNumber),
              builder: (context, match, _) {
                if (match == null) {
                  return const Text("Match not found");
                } else {
                  return EditMatchWidget(
                    gameMatch: match,
                    matchNumberController: _selectedMatchNumberController,
                    startTime: _selectedStartTime,
                    completed: _selectedCompleted,
                  );
                }
              },
            ),
          ),
        ).show(context),
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
            child: Center(
              child: CircleAvatar(
                child: Text(m.matchNumber),
                backgroundColor: m.completed ? Colors.green : Colors.red,
              ),
            ),
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
        ":robot_game:tables",
        ":teams",
        ":tournament:integrity_messages",
      ],
      child: Selector<GameMatchProvider, List<GameMatch>>(
        selector: (context, provider) => provider.matches,
        builder: (context, gameMatches, _) {
          return Column(
            children: [
              // info banner
              MatchesInfoBanner(
                gameMatches: gameMatches,
              ),
              Expanded(
                child: EditTable(
                  onAdd: () => OnAddMatch().call(context),
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

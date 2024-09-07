import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_table_signal_provider.dart';
import 'package:tms/views/match_controller/match_stage/table_status.dart';
import 'package:collection/collection.dart';

class LoadedTable extends StatelessWidget {
  final List<GameMatch> loadedMatches;
  final List<Team> teams;

  const LoadedTable({
    Key? key,
    required this.loadedMatches,
    required this.teams,
  }) : super(key: key);

  Widget _cell(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Center(
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _tableRow(BuildContext context, GameMatchTable table, TableSignalState state) {
    Team? team = teams.firstWhereOrNull((team) => team.number == table.teamNumber);
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: _cell(context, table.table),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Center(
              child: TableStatus(state: state),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _cell(context, table.teamNumber),
        ),
        Expanded(
          flex: 3,
          child: _cell(context, team?.name ?? "N/A"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<GameMatchTable> tables = [];

    for (GameMatch match in loadedMatches) {
      tables.addAll(match.gameMatchTables);
    }

    return Selector<GameTableSignalProvider, Map<String, String>>(
      selector: (context, provider) => provider.tableSignals,
      builder: (context, tableSignals, _) {
        return ListView.builder(
          itemCount: tables.length,
          itemBuilder: (context, index) {
            GameMatchTable table = tables[index];
            TableSignalState state = TableSignalState.SIG;

            // check if table is in tableSignals
            if (tableSignals.containsKey(table.table)) {
              state = TableSignalState.STANDBY;
              if (tableSignals[table.table] == table.teamNumber) {
                state = TableSignalState.READY;
              }
            }

            return _tableRow(context, table, state);
          },
        );
      },
    );
  }
}

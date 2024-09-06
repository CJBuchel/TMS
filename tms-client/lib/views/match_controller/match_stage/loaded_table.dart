import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
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

  Widget _tableRow(BuildContext context, GameMatchTable table) {
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
            child: const Center(
              child: TableStatus(status: TableSignalState.SIG),
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

    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return _tableRow(context, tables[index]);
      },
    );
  }
}

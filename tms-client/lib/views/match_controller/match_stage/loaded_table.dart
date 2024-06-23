import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/views/match_controller/match_stage/table_status.dart';

class LoadedTable extends StatelessWidget {
  final List<GameMatch> loadedMatches;

  const LoadedTable({
    Key? key,
    required this.loadedMatches,
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
    return Selector<TeamsProvider, Team>(
      selector: (_, provider) => provider.getTeam(table.teamNumber),
      builder: (context, team, _) {
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
                  child: TableStatus(table: table.table),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _cell(context, table.teamNumber),
            ),
            Expanded(
              flex: 3,
              child: _cell(context, team.name),
            ),
          ],
        );
      },
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/teams_provider.dart';

class StageTable extends StatelessWidget {
  final List<GameMatch> stagedMatches;

  const StageTable({
    Key? key,
    required this.stagedMatches,
  }) : super(key: key);

  Widget _cell(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // only top and bottom borders
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
              child: _cell(context, table.teamNumber),
            ),
            Expanded(
              flex: 2,
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

    for (GameMatch match in stagedMatches) {
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

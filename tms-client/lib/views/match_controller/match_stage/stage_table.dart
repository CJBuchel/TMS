import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class StageTable extends StatelessWidget {
  final List<GameMatch> stagedMatches;

  const StageTable({
    Key? key,
    required this.stagedMatches,
  }) : super(key: key);

  Widget _header(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<({GameMatchTable table, String matchNumber})> tableSegments = [];

    for (GameMatch match in stagedMatches) {
      for (GameMatchTable table in match.gameMatchTables) {
        tableSegments.add((
          matchNumber: match.matchNumber,
          table: table,
        ));
      }
    }

    // create rows
    List<EditTableRow> rows = [];

    for (var segment in tableSegments) {
      rows.add(
        EditTableRow(
          cells: [
            BaseTableCell(
              child: Center(child: Text(segment.matchNumber)),
            ),
            BaseTableCell(
              child: Center(child: Text(segment.table.table)),
            ),
            BaseTableCell(
              child: Center(child: Text(segment.table.teamNumber)),
            ),
            BaseTableCell(
              child: Center(
                child: Selector<TeamsProvider, Team>(
                  selector: (_, provider) => provider.getTeam(segment.table.teamNumber),
                  builder: (context, team, _) {
                    return Text(team.name);
                  },
                ),
              ),
              flex: 2,
            )
          ],
          key: segment.table.table,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      );
    }

    return EditTable(
      headers: [
        BaseTableCell(
          child: _header("Match"),
        ),
        BaseTableCell(
          child: _header("Table"),
        ),
        BaseTableCell(
          child: _header("Team"),
        ),
        BaseTableCell(
          child: _header("Name"),
          flex: 2,
        ),
      ],
      rows: rows,
      headerDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }
}

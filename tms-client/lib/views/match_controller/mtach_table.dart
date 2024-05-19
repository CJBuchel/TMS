import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/tms_date_time.dart';
import 'package:tms/widgets/tables/table.dart';

class MatchTable extends StatelessWidget {
  const MatchTable({Key? key}) : super(key: key);

  List<TmsTableCell> _getTableCells(GameMatch match) {
    List<TmsTableCell> cells = [];

    for (var gameTable in match.gameMatchTables) {
      cells.add(TmsTableCell(child: Text(gameTable.table)));
      cells.add(TmsTableCell(child: Text(gameTable.teamNumber)));
    }

    return cells;
  }

  List<TmsTableRow> _getRows(List<GameMatch> matches) {
    return matches.map((m) {
      return TmsTableRow(
        children: [
          TmsTableCell(child: Text(m.matchNumber)),
          TmsTableCell(child: Text(tmsDateTimeToString(m.startTime))),
          ..._getTableCells(m),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":robot_game:matches"],
      child: Consumer<GameMatchProvider>(
        builder: (context, provider, child) {
          return TmsTable(rows: _getRows(provider.matches));
        },
      ),
    );
  }
}

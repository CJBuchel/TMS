import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';

class MatchStage extends StatelessWidget {
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
        child: Text(label),
      ),
    );
  }

  Widget _tableRow(BuildContext context, GameMatchTable table) {
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
          flex: 1,
          child: _cell(context, "Team Name"),
        ),
      ],
    );
  }

  Widget _stagedMatchesList(BuildContext context, List<GameMatch> matches) {
    List<GameMatchTable> tables = [];

    for (GameMatch match in matches) {
      tables.addAll(match.gameMatchTables);
    }

    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return _tableRow(context, tables[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (context, provider) => provider.stagedMatches,
      builder: (context, stagedMatches, _) {
        if (stagedMatches.isEmpty) {
          return const Center(
            child: Text('No Matches Staged'),
          );
        } else {
          return _stagedMatchesList(context, stagedMatches);
        }
      },
    );
  }
}

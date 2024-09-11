import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_table_signal_provider.dart';
import 'package:tms/views/match_controller/match_stage/game_table_status.dart';
import 'package:collection/collection.dart';

class LoadedTable extends StatefulWidget {
  final List<GameMatch> loadedMatches;
  final List<Team> teams;

  const LoadedTable({
    Key? key,
    required this.loadedMatches,
    required this.teams,
  }) : super(key: key);

  @override
  _LoadedTableState createState() => _LoadedTableState();
}

class _LoadedTableState extends State<LoadedTable> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

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
    Team? team = widget.teams.firstWhereOrNull((team) => team.teamNumber == table.teamNumber);
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
              child: GameTableStatus(state: state, blinkController: _blinkController),
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

    for (GameMatch match in widget.loadedMatches) {
      tables.addAll(match.gameMatchTables);
    }

    return Selector<GameTableSignalProvider, Map<String, String>>(
      selector: (context, provider) => provider.tableSignals,
      shouldRebuild: (previous, next) => previous.values.toList() != next.values.toList(),
      builder: (context, tableSignals, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                childCount: tables.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

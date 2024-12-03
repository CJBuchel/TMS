import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/widgets/animated/infinite_horizontal_list.dart';

class NextMatchRow extends StatelessWidget {
  final GameMatch nextMatch;
  final int index;

  const NextMatchRow({
    Key? key,
    required this.nextMatch,
    required this.index,
  }) : super(key: key);

  Widget _teamOnTable(GameMatchTable gmTable, double childWidth) {
    return Selector<TeamsProvider, Team>(
      selector: (_, provider) => provider.getTeam(gmTable.teamNumber),
      builder: (context, team, _) {
        return Container(
          width: childWidth,
          child: Center(
            child: Text("${gmTable.teamNumber} | ${team.name} | ${gmTable.table}"),
          ),
        );
      },
    );
  }

  List<Widget> _teamsOnTables(List<GameMatchTable> gmTables, double childWidth) {
    return gmTables.map((gmTable) => _teamOnTable(gmTable, childWidth)).toList();
  }

  @override
  Widget build(BuildContext context) {
    Color lightColor = index.isEven ? const Color(0xFF9CDEFF) : const Color(0xFF81FFD7);
    Color darkColor = index.isEven ? const Color(0xFF1B6A92) : const Color(0xFF27A07A);

    double childWidth = 400;

    return Row(
      children: [
        Container(
          width: 200,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
          decoration: ShapeDecoration(
            // color: Colors.white,
            color: Theme.of(context).brightness == Brightness.light ? lightColor : darkColor,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
          ),
          child: Center(
            child: Text(
              "#${nextMatch.matchNumber} | ${nextMatch.startTime.toString()}",
            ),
          ),
        ),
        Expanded(
          child: AnimatedInfiniteHorizontalList(
            scrollSpeed: 25,
            children: _teamsOnTables(nextMatch.gameMatchTables, childWidth),
            childWidth: childWidth,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/color_modifiers.dart';

class _TeamOnTableInformation {
  final String teamNumber;
  final String table;
  final String teamName;
  final String teamAffiliation;

  _TeamOnTableInformation({
    required this.teamNumber,
    required this.table,
    required this.teamName,
    required this.teamAffiliation,
  });
}

class NextMatchInfo extends StatelessWidget {
  final List<GameMatch> nextMatches;

  const NextMatchInfo({
    required this.nextMatches,
  });

  Color _getColor(int i) {
    List<Color> colors = [
      Colors.teal,
      Colors.purple,
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.blueGrey,
    ];

    return colors[i % colors.length];

    // return colors[i % colors.length].withOpacity(0.2);
  }

  Widget _headerTextCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _textCell(BuildContext context, String text, {int flex = 1, bool isEnd = false}) {
    BorderSide borderSide = BorderSide(
      color: Theme.of(context).dividerColor,
      width: 1,
    );

    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            right: isEnd ? BorderSide.none : borderSide,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            overflow: TextOverflow.ellipsis,
            // color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _teamOnTableWidget(GameMatchTable gameMatchTable, Color backgroundColor, int index) {
    return Selector<TeamsProvider, _TeamOnTableInformation>(
      selector: (_, teamsProvider) {
        final team = teamsProvider.getTeam(gameMatchTable.teamNumber);
        return _TeamOnTableInformation(
          teamNumber: team.teamNumber,
          table: gameMatchTable.table,
          teamName: team.name,
          teamAffiliation: team.affiliation,
        );
      },
      builder: (context, teamInfo, _) {
        return Container(
          margin: const EdgeInsets.all(10),
          // padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  // color: Colors.teal,
                  color: _getColor(index),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    _headerTextCell("Team", flex: 1),
                    _headerTextCell("On Table", flex: 1),
                    _headerTextCell("Name", flex: 2),
                    _headerTextCell("Affiliation", flex: 3),
                  ],
                ),
              ),
              Row(
                children: [
                  _textCell(context, teamInfo.teamNumber, flex: 1),
                  _textCell(context, teamInfo.table, flex: 1),
                  _textCell(context, teamInfo.teamName, flex: 2),
                  _textCell(context, teamInfo.teamAffiliation, flex: 3, isEnd: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<GameMatchTable> tables = nextMatches.map((m) => m.gameMatchTables).expand((t) => t).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: tables.length,
            (context, index) {
              Color evenBackground = Theme.of(context).cardColor;
              Color oddBackground = lighten(Theme.of(context).cardColor, 0.05);
              Color backgroundColor = index % 2 == 0 ? evenBackground : oddBackground;
              return _teamOnTableWidget(tables[index], backgroundColor, index);
            },
          ),
        ),
      ],
    );
  }
}

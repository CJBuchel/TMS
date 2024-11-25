import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/teams_provider.dart';

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

  Widget _teamOnTableWidget(GameMatchTable gameMatchTable) {
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
        return Row(
          children: [
            Text(teamInfo.teamNumber),
            Text(teamInfo.table),
            Text(teamInfo.teamName),
            Text(teamInfo.teamAffiliation),
          ],
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
              return _teamOnTableWidget(tables[index]);
            },
          ),
        ),
      ],
    );
  }
}

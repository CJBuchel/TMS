import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/match_controller/match_stage/loaded_table.dart';
import 'package:tms/views/match_controller/match_stage/stage_table.dart';
import 'package:tms/views/match_controller/match_stage/stage_table_data.dart';

class _LoadedMatchData {
  final List<StageTableData> stagedMatchData;
  final List<GameMatch> loadedMatches;
  final List<String> stagedMatchNumbers;
  final List<String> loadedMatchNumbers;
  final bool hasStagedMatches;
  final bool hasLoadedMatches;

  _LoadedMatchData({
    required this.stagedMatchData,
    required this.loadedMatches,
    required this.stagedMatchNumbers,
    required this.loadedMatchNumbers,
    required this.hasStagedMatches,
    required this.hasLoadedMatches,
  });
}

class MatchStage extends StatelessWidget {
  const MatchStage({Key? key}) : super(key: key);

  Widget _matchStageTables(BuildContext context, List<Team> teams) {
    return Selector2<GameMatchProvider, GameMatchStatusProvider, _LoadedMatchData>(
      selector: (_, matchProvider, statusProvider) {
        List<StageTableData> stagedTableData = [];
        List<GameMatch> stagedMatches = statusProvider.getStagedMatches(matchProvider.matches);
        List<GameMatch> loadedMatches = statusProvider.getLoadedMatches(matchProvider.matches);

        for (var match in stagedMatches) {
          for (var table in match.gameMatchTables) {
            stagedTableData.add(
              StageTableData(
                table: table,
                submittedPrior: statusProvider.hasTableSubmittedPriorScoreSheets(table.table, matchProvider.matches),
                matchNumber: match.matchNumber,
                team: teams.firstWhere((team) => team.number == table.teamNumber),
              ),
            );
          }
        }

        return _LoadedMatchData(
          stagedMatchData: stagedTableData,
          loadedMatches: loadedMatches,
          stagedMatchNumbers: stagedMatches.map((match) => match.matchNumber).toList(),
          loadedMatchNumbers: loadedMatches.map((match) => match.matchNumber).toList(),
          hasStagedMatches: stagedMatches.isNotEmpty,
          hasLoadedMatches: loadedMatches.isNotEmpty,
        );
      },
      builder: (context, data, _) {
        if (data.hasLoadedMatches) {
          return LoadedTable(loadedMatches: data.loadedMatches, teams: teams);
        } else if (data.hasStagedMatches) {
          return StageTable(tableData: data.stagedMatchData, stagedMatchNumbers: data.stagedMatchNumbers);
        } else {
          return const Center(
            child: Text('No Matches Staged'),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TeamsProvider, List<Team>>(
      selector: (_, provider) => provider.teams,
      builder: (context, teams, __) {
        return _matchStageTables(context, teams);
      },
    );
  }
}

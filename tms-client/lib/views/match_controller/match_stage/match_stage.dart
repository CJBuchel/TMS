import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/match_controller/match_stage/loaded_table.dart';
import 'package:tms/views/match_controller/match_stage/stage_table.dart';

class _LoadedMatchData {
  final List<GameMatch> stagedMatches;
  final List<GameMatch> loadedMatches;

  _LoadedMatchData({
    required this.stagedMatches,
    required this.loadedMatches,
  });
}

class MatchStage extends StatelessWidget {
  const MatchStage({Key? key}) : super(key: key);

  Widget _matchStageTables(BuildContext context, List<Team> teams) {
    return Selector<GameMatchProvider, _LoadedMatchData>(
      selector: (_, provider) {
        return _LoadedMatchData(
          stagedMatches: provider.stagedMatches,
          loadedMatches: provider.loadedMatches,
        );
      },
      builder: (context, data, _) {
        if (data.loadedMatches.isNotEmpty) {
          return LoadedTable(loadedMatches: data.loadedMatches, teams: teams);
        } else if (data.stagedMatches.isNotEmpty) {
          return StageTable(stagedMatches: data.stagedMatches);
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
    return EchoTreeLifetime(
      trees: [":teams"],
      child: Selector<TeamsProvider, List<Team>>(
        selector: (_, provider) => provider.teams,
        builder: (context, teams, __) {
          return _matchStageTables(context, teams);
        },
      ),
    );
  }
}

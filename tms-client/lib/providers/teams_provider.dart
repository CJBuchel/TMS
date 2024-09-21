import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:collection/collection.dart';

class TeamsProvider extends EchoTreeProvider<String, Team> {
  TeamsProvider() : super(tree: ":teams", fromJsonString: (json) => Team.fromJsonString(json: json));

  List<Team> get teams {
    return sortTeamsByNumber(this.items.values.toList());
  }

  Team getTeam(String teamNumber) {
    // find team from team number
    Team? team = teams.firstWhereOrNull((t) => t.teamNumber == teamNumber);
    if (team != null) {
      return team;
    } else {
      // if team is not found, return a default team
      return const Team(
        affiliation: 'N/A',
        name: 'N/A',
        teamNumber: 'N/A',
        ranking: 0,
      );
    }
  }

  Map<String, Team> get teamsMap => this.items;

  Team getTeamById(String teamId) {
    Team? team = this.items[teamId];

    if (team != null) {
      return team;
    } else {
      return const Team(
        affiliation: 'N/A',
        name: 'N/A',
        teamNumber: 'N/A',
        ranking: 0,
      );
    }
  }
}

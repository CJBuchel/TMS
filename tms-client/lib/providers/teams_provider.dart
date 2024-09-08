import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/utils/sorter_util.dart';

abstract class _BaseTeamsProvider extends EchoTreeProvider<String, Team> {
  _BaseTeamsProvider() : super(tree: ":teams", fromJsonString: (json) => Team.fromJsonString(json: json));

  List<Team> get teams {
    return sortTeamsByNumber(this.items.values.toList());
  }

  Team getTeam(String teamNumber) {
    // find team from team number
    try {
      return teams.firstWhere((t) => t.number == teamNumber);
    } catch (e) {
      return const Team(
        affiliation: 'N/A',
        name: 'N/A',
        number: 'N/A',
        ranking: 0,
      );
    }
  }
}

class TeamsProvider extends _BaseTeamsProvider {
  TeamsProvider();
}

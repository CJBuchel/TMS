import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/schemas/database_schema.dart';

abstract class _BaseTeamsProvider extends EchoTreeProvider<String, Team> {
  _BaseTeamsProvider() : super(tree: ":teams", fromJson: (json) => Team.fromJson(json));

  List<Team> get teams {
    return this.items.values.toList();
  }

  Team getTeam(String teamNumber) {
    // find team from team number
    try {
      return teams.firstWhere((t) => t.number == teamNumber);
    } catch (e) {
      return Team(
        affiliation: 'N/A',
        cloudId: '',
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

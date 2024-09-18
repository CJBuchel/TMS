import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/views/teams/edit_team.dart';
import 'package:tms/views/teams/team_selector.dart';

class Teams extends StatelessWidget {
  Teams({Key? key}) : super(key: key);

  final ValueNotifier<Team?> _selectedTeam = ValueNotifier<Team?>(null);

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":teams",
        ":robot_game:game_scores",
      ],
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TeamSelector(
              onTeamSelected: (t) => _selectedTeam.value = t,
            ),
          ),
          Expanded(
            flex: 2,
            child: ValueListenableBuilder(
              valueListenable: _selectedTeam,
              builder: (context, team, _) {
                if (team == null) {
                  return const Center(
                    child: Text("No team selected"),
                  );
                } else {
                  return EditTeam(team: team);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

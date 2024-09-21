import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/teams/team_editor/team_editor.dart';
import 'package:tms/views/teams/team_selector.dart';

class Teams extends StatelessWidget {
  Teams({Key? key}) : super(key: key);

  final ValueNotifier<String?> _selectedTeamId = ValueNotifier(null);

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
              onTeamSelected: (id) => _selectedTeamId.value = id,
            ),
          ),
          Expanded(
            flex: 2,
            child: ValueListenableBuilder(
              valueListenable: _selectedTeamId,
              builder: (context, teamId, _) {
                if (teamId == null) {
                  return const Center(
                    child: Text("No team selected"),
                  );
                } else {
                  return TeamEditor(
                    teamId: teamId,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tms/views/teams/team_editor/team_info_banner/team_info_banner.dart';
import 'package:tms/views/teams/team_editor/team_scores/team_scores_editor.dart';
import 'package:tms/views/teams/team_editor/team_settings/team_settings_editor.dart';
import 'package:tms/widgets/team_widgets/with_team_details.dart';

class TeamEditor extends StatelessWidget {
  final String teamId;

  TeamEditor({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  final TextEditingController _teamNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WithTeamDetails(
      teamId: teamId,
      builder: (context, team, teamMatches, teamSessions, teamScores) {
        _teamNumberController.text = team.teamNumber;
        return Column(
          children: [
            // team checks
            TeamInfoBanner(
              teamId: teamId,
              team: team,
            ),
            // team settings
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: [
                      TeamSettingsEditor(
                        teamId: teamId,
                        team: team,
                      ),
                      const SizedBox(height: 20),
                      TeamScoresEditor(
                        teamId: teamId,
                        teamScores: teamScores,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

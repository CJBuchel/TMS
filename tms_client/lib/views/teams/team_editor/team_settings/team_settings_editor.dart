import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/teams/team_editor/team_settings/update_team_button.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';
import 'package:tms/widgets/multi_value_listener_builders.dart';

class TeamSettingsEditor extends StatefulWidget {
  final String teamId;
  final Team team;

  TeamSettingsEditor({
    Key? key,
    required this.teamId,
    required this.team,
  }) : super(key: key);

  @override
  _TeamSettingsEditorState createState() => _TeamSettingsEditorState();
}

class _TeamSettingsEditorState extends State<TeamSettingsEditor> {
  final ExpansionController _expansionController = ExpansionController(isExpanded: true);

  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamAffiliationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _teamNumberController.text = widget.team.teamNumber;
    _teamNameController.text = widget.team.name;
    _teamAffiliationController.text = widget.team.affiliation;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpandableTile(
        controller: _expansionController,
        header: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const Text(
                "Team Settings",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _expansionController,
                builder: (context, isExpanded, _) {
                  return Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: lighten(Theme.of(context).cardColor, 0.05),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              // team name field
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 15),
                child: TextField(
                  controller: _teamNumberController,
                  decoration: const InputDecoration(
                    labelText: "Team Number",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // team name field
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 15),
                child: TextField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: "Team Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // team affiliation field
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 15),
                child: TextField(
                  controller: _teamAffiliationController,
                  decoration: const InputDecoration(
                    labelText: "Team Affiliation",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // update button
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ValueListenableBuilder3(
                      first: _teamNumberController,
                      second: _teamNameController,
                      third: _teamAffiliationController,
                      builder: (context, teamNumber, teamName, teamAffiliation, _) {
                        return UpdateTeamButton(
                          teamId: widget.teamId,
                          updatedTeam: Team(
                            teamNumber: teamNumber.text,
                            name: teamName.text,
                            affiliation: teamAffiliation.text,
                            ranking: widget.team.ranking,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

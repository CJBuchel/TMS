import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/teams/team_editor/update_team_button.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';
import 'package:tms/widgets/multi_value_listener_builders.dart';

class GeneralTeamSettings extends StatelessWidget {
  final String teamId;
  final Team team;

  GeneralTeamSettings({
    Key? key,
    required this.teamId,
    required this.team,
  }) : super(key: key);

  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamAffiliationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _teamNumberController.text = team.teamNumber;
    _teamNameController.text = team.name;
    _teamAffiliationController.text = team.affiliation;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpandableTile(
        header: const Padding(
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
              Icon(
                Icons.keyboard_arrow_down,
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
                  decoration: const InputDecoration(labelText: "Team Number"),
                ),
              ),
              // team name field
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 15),
                child: TextField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(labelText: "Team Name"),
                ),
              ),
              // team affiliation field
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 15),
                child: TextField(
                  controller: _teamAffiliationController,
                  decoration: const InputDecoration(labelText: "Team Affiliation"),
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
                          teamId: teamId,
                          updatedTeam: Team(
                            teamNumber: teamNumber.text,
                            name: teamName.text,
                            affiliation: teamAffiliation.text,
                            ranking: team.ranking,
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

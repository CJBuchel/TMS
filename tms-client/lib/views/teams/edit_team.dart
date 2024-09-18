import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class EditTeam extends StatelessWidget {
  final Team team;

  EditTeam({Key? key, required this.team}) : super(key: key);

  final TextEditingController _teamNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _teamNumberController.text = team.teamNumber;
    return Column(
      children: [
        // team checks
        const Row(
          children: [
            // matches
            // sessions
            // warnings
            // errors
          ],
        ),
        // @TODO, format this nicely, or put inside accordion
        Container(
          margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
          child: TextField(
            controller: _teamNumberController,
            decoration: const InputDecoration(
              labelText: "Team Number",
              hintText: "Enter team number",
            ),
          ),
        ),
        // team name field
        // team affiliation field
        // row of buttons (delete/update)

        // scores
      ],
    );
  }
}

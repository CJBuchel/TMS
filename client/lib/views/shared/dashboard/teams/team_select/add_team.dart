import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddTeamButton extends StatelessWidget {
  AddTeamButton({Key? key}) : super(key: key);

  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamAffiliationController = TextEditingController();

  void showError(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Error",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            )
          ],
        );
      }),
    );
  }

  void _addTeam(BuildContext context) {
    addTeamRequest(_teamNumberController.text, _teamNameController.text, _teamAffiliationController.text).then(
      (res) {
        if (res != HttpStatus.ok) {
          showNetworkError(res, context);
        } else {
          // snackbar
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Team added"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // team number
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: TextField(
            controller: _teamNumberController,
            decoration: const InputDecoration(
              labelText: "Team Number*",
              hintText: "Enter team number",
            ),
            keyboardType: TextInputType.number,
          ),
        ),

        // team name
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: TextField(
            controller: _teamNameController,
            decoration: const InputDecoration(
              labelText: "Team Name",
              hintText: "Enter team name",
            ),
          ),
        ),

        // team affiliation
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: TextField(
            controller: _teamAffiliationController,
            decoration: const InputDecoration(
              labelText: "Team Affiliation",
              hintText: "Enter team affiliation",
            ),
          ),
        ),
      ],
    );
  }

  void _addTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add, color: Colors.green),
              SizedBox(width: 10),
              Text("Add Team"),
            ],
          ),
          content: _content(),
          actions: <Widget>[
            // cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),

            // add button
            TextButton(
              onPressed: () {
                if (_teamNumberController.text.isEmpty) {
                  showError("Team number cannot be empty", context);
                } else {
                  Navigator.of(context).pop();
                  _addTeam(context);
                }
              },
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.add,
        color: Colors.green,
      ),
      onPressed: () {
        _addTeamDialog(context);
      },
    );
  }
}

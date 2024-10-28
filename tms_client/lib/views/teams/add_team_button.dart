import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/services/team_service.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class AddTeamButton extends StatelessWidget {
  AddTeamButton({
    Key? key,
  }) : super(key: key);

  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _affiliationController = TextEditingController();

  void _confirmAddTeam(BuildContext context) {
    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        return TeamService().insertTeam(
          null,
          Team(
            teamNumber: _teamNumberController.text,
            name: _teamNameController.text,
            affiliation: _affiliationController.text,
            ranking: 0,
          ),
        );
      },
      style: DialogStyle.success(
        title: "Add Team",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _teamNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Team Number",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _teamNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Team Name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _affiliationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Affiliation",
                ),
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        overlayColor: Colors.white,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.green),
        ),
      ),
      icon: const Icon(Icons.add),
      label: const Text("Add Team"),
      onPressed: () => _confirmAddTeam(context),
    );
  }
}

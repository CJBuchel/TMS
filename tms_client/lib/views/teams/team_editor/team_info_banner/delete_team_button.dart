import 'package:flutter/material.dart';
import 'package:tms/services/team_service.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class DeleteTeamButton extends StatelessWidget {
  final String teamId;

  const DeleteTeamButton({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  void _confirmDeleteTeam(BuildContext context) {
    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        return TeamService().removeTeam(teamId);
      },
      style: DialogStyle.error(
        title: "Delete Team",
        message: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to delete this team?\n"),
            const Text(
              "Deleting this team WILL remove them from all matches and judging sessions. Along with existing scores.\n",
              softWrap: true,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "This action cannot be undone.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.red),
        ),
      ),
      icon: const Icon(Icons.delete),
      label: const Text("Delete Team"),
      onPressed: () => _confirmDeleteTeam(context),
    );
  }
}

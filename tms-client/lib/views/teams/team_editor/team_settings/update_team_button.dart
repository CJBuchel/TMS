import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/services/team_service.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';

class UpdateTeamButton extends StatelessWidget {
  final String teamId;
  final Team updatedTeam;

  void _confirmUpdateTeam(BuildContext context) {
    ConfirmFutureDialog(
      style: ConfirmDialogStyle.warn(
        title: "Update Team",
        message: const Text("Are you sure you want to update this team?"),
      ),
      onStatusConfirmFuture: () {
        return TeamService().insertTeam(
          teamId,
          updatedTeam,
        );
      },
    ).show(context);
  }

  const UpdateTeamButton({
    Key? key,
    required this.teamId,
    required this.updatedTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.send,
        color: Colors.blue,
      ),
      onPressed: () => _confirmUpdateTeam(context),
    );
  }
}

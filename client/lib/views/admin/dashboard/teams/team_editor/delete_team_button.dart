import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeleteTeamButton extends StatelessWidget {
  final String teamNumber;
  final Function() onTeamDelete;
  const DeleteTeamButton({
    Key? key,
    required this.onTeamDelete,
    required this.teamNumber,
  }) : super(key: key);

  void _deleteTeam(BuildContext context) {
    deleteTeamRequest(teamNumber).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error deleting team $teamNumber");
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted team $teamNumber"),
            backgroundColor: Colors.red,
          ),
        );
      }
      onTeamDelete.call();
    });
  }

  void _deleteTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Text("Delete Team $teamNumber?"),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Deleting the team will also remove them from all matches and judging session"),
              Text("Are you sure?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteTeam(context);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _deleteTeamDialog(context);
      },
      icon: const Icon(Icons.delete_outline),
      label: const Text("Delete"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeleteScore extends StatelessWidget {
  final Team team;
  final int index;
  final Function()? onDelete;
  const DeleteScore({
    Key? key,
    required this.team,
    required this.index,
    this.onDelete,
  }) : super(key: key);

  void _deleteScore(BuildContext context) {
    final updatedTeam = team;
    updatedTeam.gameScores.removeAt(index);
    updateTeamRequest(team.teamNumber, updatedTeam).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error deleting score at index $index");
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted score for team ${team.teamNumber}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      onDelete?.call();
    });
  }

  void _deleteScoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Delete Score?"),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to delete this teams score?"),
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
                Navigator.of(context).pop();
                _deleteScore(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _deleteScoreDialog(context);
      },
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
    );
  }
}

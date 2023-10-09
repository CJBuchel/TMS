import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeleteMatch extends StatelessWidget {
  final Function() onDeleteMatch;
  final String matchNumber;
  const DeleteMatch({
    Key? key,
    required this.onDeleteMatch,
    required this.matchNumber,
  }) : super(key: key);

  void _deleteMatch(BuildContext context) {
    deleteMatchRequest(matchNumber).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error deleting $matchNumber");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted $matchNumber"),
            backgroundColor: Colors.green,
          ),
        );
      }

      onDeleteMatch();
    });
  }

  void _deleteMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              Text("Delete Match?"),
            ],
          ),
          content: Text("Are you sure you want to delete match $matchNumber?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteMatch(context);
                Navigator.of(context).pop();
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
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _deleteMatchDialog(context),
    );
  }
}

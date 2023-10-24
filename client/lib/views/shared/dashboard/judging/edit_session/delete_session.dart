import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeleteSession extends StatelessWidget {
  final Function()? onDeleteSession;
  final String sessionNumber;
  const DeleteSession({
    Key? key,
    this.onDeleteSession,
    required this.sessionNumber,
  }) : super(key: key);

  void _deleteSession(BuildContext context) {
    deleteJudgingSessionRequest(sessionNumber).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error deleting $sessionNumber");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(" Deleted $sessionNumber"),
            backgroundColor: Colors.red,
          ),
        );
      }

      onDeleteSession?.call();
    });
  }

  void _deleteSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              Text("Delete Session?"),
            ],
          ),
          content: Text("Are you sure you want to delete session $sessionNumber?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteSession(context);
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
      onPressed: () => _deleteSessionDialog(context),
    );
  }
}

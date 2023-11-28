import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/database_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeleteBackupButton extends StatelessWidget {
  final String backupName;
  final Function() onDeleteBackup;

  const DeleteBackupButton({
    Key? key,
    required this.backupName,
    required this.onDeleteBackup,
  }) : super(key: key);

  void _deleteBackup(BuildContext context) {
    deleteBackupRequest(backupName).then((res) {
      if (res != HttpStatus.ok) {
        showNetworkError(res, context);
      } else {
        onDeleteBackup();
        // snackbar
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Deleted backup"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _deleteBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text("Delete Backup"),
              ),
            ],
          ),
          content: const Text("Are you sure you want to delete this backup?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteBackup(context);
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
      onPressed: () => _deleteBackupDialog(context),
      icon: const Icon(Icons.delete, color: Colors.red),
    );
  }
}

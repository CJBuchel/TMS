import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/database_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class CreateBackupButton extends StatelessWidget {
  final Function() onCreateBackup;
  const CreateBackupButton({
    Key? key,
    required this.onCreateBackup,
  }) : super(key: key);

  void _createBackup(BuildContext context) {
    createBackupRequest().then((res) {
      if (res != HttpStatus.ok) {
        showNetworkError(res, context);
      } else {
        // snackbar
        onCreateBackup();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Created backup"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _createBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.create_new_folder_outlined, color: Colors.green),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text("Create New Backup"),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to create a backup?"),
              Text("This will overwrite older snapshots"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // create backup
                _createBackup(context);
              },
              child: const Text("Create", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _createBackupDialog(context),
      icon: const Icon(Icons.create_new_folder_outlined, color: Colors.green),
    );
  }
}

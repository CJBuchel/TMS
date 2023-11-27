import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/backup_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class RestoreBackupButton extends StatelessWidget {
  final String backupName;
  final Function onRestore;

  const RestoreBackupButton({
    Key? key,
    required this.backupName,
    required this.onRestore,
  }) : super(key: key);

  void _restoreBackup(BuildContext context) {
    restoreBackupRequest(backupName).then((res) {
      if (res != HttpStatus.ok) {
        // show error
        showNetworkError(res, context);
      } else {
        onRestore();
        // snackbar
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Restored backup"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _restoreBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text("Restore Backup"),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to restore this backup?"),
              Text(
                "This WILL overwrite all current data",
                style: TextStyle(color: Colors.red),
              ),
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
                _restoreBackup(context);
              },
              child: const Text(
                "Restore",
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
      ),
      onPressed: () => _restoreBackupDialog(context),
      icon: const Icon(Icons.restart_alt_sharp, color: Colors.red),
      label: const Text("Restore", style: TextStyle(color: Colors.red)),
    );
  }
}

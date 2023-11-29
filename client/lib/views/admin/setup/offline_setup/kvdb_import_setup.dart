import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tms/requests/database_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class KVDBImportSetup extends StatelessWidget {
  const KVDBImportSetup({
    Key? key,
  }) : super(key: key);

  void _uploadDatabase(BuildContext context, FilePickerResult result) {
    var name = result.files.single.name;
    var data = result.files.single.bytes;
    if (data != null && data.isNotEmpty && name.isNotEmpty) {
      uploadRestoreBackupRequest(name, data).then((res) {
        if (res == HttpStatus.ok) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    "Successful Import",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text("The database has been imported."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          showNetworkError(res, context, subMessage: "Failed to upload database.");
        }
      });
    } else {
      showNetworkError(HttpStatus.badRequest, context, subMessage: "Failed to upload database.");
    }
  }

  void _uploadFile(BuildContext context) {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'kvdb.zip'],
    ).then((res) {
      if (res != null) {
        _uploadDatabase(context, res);
      }
    });
  }

  Future<bool> _selectDatabaseDialog(BuildContext context) {
    var completer = Completer<bool>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Import KVDB",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to import the database?"),
              SizedBox(height: 10),
              Text("This WILL overwrite the current database.", style: TextStyle(color: Colors.red)),
            ],
          ),

          // buttons
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                completer.complete(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                completer.complete(true);
              },
              child: const Text("Continue", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 50,
        width: 200,
        child: ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ),
          onPressed: () {
            _selectDatabaseDialog(context).then((shouldUpload) {
              if (shouldUpload) {
                _uploadFile(context);
              }
            });
          },
          icon: const Icon(Icons.upload_file_sharp),
          label: const Text("Import KVDB"),
        ),
      ),
    );
  }
}

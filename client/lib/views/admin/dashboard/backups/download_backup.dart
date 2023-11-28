import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/requests/database_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DownloadBackupButton extends StatelessWidget {
  final String backupName;

  const DownloadBackupButton({
    Key? key,
    required this.backupName,
  }) : super(key: key);

  void _downloadBackup(BuildContext context) {
    // download backup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: downloadBackupRequest(backupName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text("Downloading..."),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
              if (snapshot.hasData) {
                if (snapshot.data?.item1 == HttpStatus.ok) {
                  Logger().i("Length: ${snapshot.data?.item2.length}");
                  FileSaver.instance.saveFile(
                    name: backupName,
                    bytes: snapshot.data?.item2,
                    mimeType: MimeType.zip,
                  );
                } else {
                  showNetworkError(snapshot.data!.item1, context);
                }
              }

              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _downloadBackup(context),
      icon: const Icon(Icons.download, color: Colors.blue),
    );
  }
}

import 'package:flutter/material.dart';

class BackupSetup extends StatelessWidget {
  final TextEditingController backupIntervalController;
  final TextEditingController backupCountController;

  const BackupSetup({
    Key? key,
    required this.backupIntervalController,
    required this.backupCountController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text("Backup Times", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),

        // backup interval
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: TextField(
            controller: backupIntervalController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Backup Interval',
              hintText: 'Time between backups in minutes: e.g `30`',
            ),
          ),
        ),

        // backup count
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: TextField(
            controller: backupCountController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Backup Count',
              hintText: 'Number of backups to keep: e.g `5`',
            ),
          ),
        ),
      ],
    );
  }
}

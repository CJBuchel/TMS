import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/generated/infra/network_schemas/backup_requests.dart';
import 'package:tms/services/backups_service.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';
import 'package:tms/widgets/tables/base_table.dart';

class Backups extends StatefulWidget {
  @override
  _BackupsState createState() => _BackupsState();
}

class _BackupsState extends State<Backups> {
  List<BackupGetNamesInfo> _backups = [];

  void _fetchBackups() async {
    final response = await BackupsService().getBackups();
    if (response.$1 == HttpStatus.ok && response.$2 != null) {
      if (mounted) {
        setState(() {
          // sort backups by timestamp (newest first)
          response.$2!.backups.sort((a, b) => b.timestamp.compareTo(other: a.timestamp));
          _backups = response.$2!.backups;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBackups();
  }

  BaseTableCell _cell(Widget child) {
    return BaseTableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: child),
      ),
    );
  }

  List<BaseTableRow> _buildRows() {
    return _backups.map((backup) {
      return BaseTableRow(
        decoration: BoxDecoration(
          // border
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              // width: 1,
            ),
          ),
        ),
        cells: [
          _cell(Text(backup.timestamp.toString())),
          _cell(
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                overlayColor: Colors.grey,
                shadowColor: Colors.red,
              ),
              icon: const Icon(Icons.restart_alt_rounded, color: Colors.red),
              label: const Text('Restore', style: TextStyle(color: Colors.red)),
              onPressed: () {
                ConfirmFutureDialog(
                  onStatusConfirmFuture: () => BackupsService().restoreBackup(backup.fileName),
                  style: ConfirmDialogStyle.error(
                    title: "Restore Backup",
                    message: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Are you sure you want to restore this backup?"),
                        Text("This WILL overwrite the current state of the system."),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning, color: Colors.orange),
                                  Text(" - CAUTION PANIC CODE - "),
                                  Icon(Icons.warning, color: Colors.orange),
                                ],
                              ),
                              Text(
                                "Sled has no safety. Server can and will PANIC on error",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).show(context);
              },
            ),
          ),
          _cell(Text(backup.fileName)),
          _cell(
            IconButton(
              onPressed: () {
                BackupsService().downloadBackup(backup.fileName).then((status) {
                  if (status != HttpStatus.ok) {
                    SnackBarDialog.fromStatus(
                      message: "Download Backup",
                      status: status,
                    ).show(context);
                  }
                });
              },
              icon: const Icon(Icons.download, color: Colors.blue),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // warning text
        const Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Notice: Backups are not stateful, reload to fetch updates",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                onPressed: () => _fetchBackups(),
                icon: const Icon(Icons.replay, color: Colors.orange),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                onPressed: () => ConfirmFutureDialog(
                  onStatusConfirmFuture: () => BackupsService().createBackup(),
                  style: ConfirmDialogStyle.success(
                    title: "Create Backup",
                    message: const Text("Are you sure you want to create a backup?"),
                  ),
                ).show(context),
                icon: const Icon(Icons.backup, color: Colors.green),
              ),
            ),
          ],
        ),
        Expanded(
          child: BaseTable(
            headers: [
              _cell(const Text(
                'Timestamp',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              _cell(const Text(
                'Restore',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              _cell(const Text(
                'File Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              _cell(const Text(
                'Download',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
            ],
            rows: _buildRows(),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/database_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/backups/backups_table.dart';
import 'package:tms/views/admin/dashboard/backups/create_backup.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class Backups extends StatefulWidget {
  const Backups({Key? key}) : super(key: key);

  @override
  State<Backups> createState() => _BackupsState();
}

class _BackupsState extends State<Backups> {
  final ValueNotifier<List<Backup>> _backupsNotifier = ValueNotifier<List<Backup>>([]);

  set _setBackups(List<Backup> backups) {
    if (mounted) {
      _backupsNotifier.value = backups;
    }
  }

  void _fetchBackups() async {
    if (await Network().isConnected() && NetworkAuth().loginState.value) {
      getBackupsRequest().then((backups) {
        if (backups.item1 != HttpStatus.ok) {
          showNetworkError(backups.item1, context, subMessage: "Failed to fetch backups");
        } else {
          _setBackups = backups.item2;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchBackups());

    NetworkHttp().httpState.addListener(_fetchBackups);
    NetworkWebSocket().wsState.addListener(_fetchBackups);
    NetworkAuth().loginState.addListener(_fetchBackups);
  }

  @override
  void dispose() {
    NetworkHttp().httpState.removeListener(_fetchBackups);
    NetworkWebSocket().wsState.removeListener(_fetchBackups);
    NetworkAuth().loginState.removeListener(_fetchBackups);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              width: constraints.maxWidth,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _fetchBackups(),
                    icon: const Icon(Icons.refresh, color: Colors.orange),
                  ),
                  CreateBackupButton(
                    onCreateBackup: _fetchBackups,
                  ),
                ],
              ),
            ),

            // table section
            Expanded(
              child: BackupsTable(
                backupsNotifier: _backupsNotifier,
                fetchBackups: _fetchBackups,
              ),
            ),
          ],
        );
      },
    );
  }
}

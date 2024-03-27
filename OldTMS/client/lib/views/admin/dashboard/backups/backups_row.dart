import 'package:flutter/material.dart';
import 'package:tms/views/admin/dashboard/backups/delete_backup.dart';
import 'package:tms/views/admin/dashboard/backups/download_backup.dart';
import 'package:tms/views/admin/dashboard/backups/restore_button.dart';

class BackupsRow extends StatelessWidget {
  final String backupName;
  final String backupDate;
  final Function() fetchBackups;

  const BackupsRow({
    Key? key,
    required this.backupName,
    required this.backupDate,
    required this.fetchBackups,
  }) : super(key: key);

  Widget _styledCell(Widget inner, {Color? color}) {
    return Container(
      color: color,
      child: Center(
        child: inner,
      ),
    );
  }

  Widget _styledTextCell(String label, {Color? color, Color? textColor}) {
    return _styledCell(
      color: color,
      Text(
        label,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // delete button
          Expanded(
            flex: 1,
            child: _styledCell(
              DeleteBackupButton(
                backupName: backupName,
                onDeleteBackup: fetchBackups,
              ),
            ),
          ),

          // date
          Expanded(
            flex: 2,
            child: _styledTextCell(backupDate),
          ),

          // restore button
          Expanded(
            flex: 1,
            child: _styledCell(
              RestoreBackupButton(
                backupName: backupName,
                onRestore: fetchBackups,
              ),
            ),
          ),

          // file
          Expanded(
            flex: 3,
            child: _styledTextCell(backupName),
          ),

          // download button
          Expanded(
            flex: 1,
            child: DownloadBackupButton(backupName: backupName),
          ),
        ],
      ),
    );
  }
}

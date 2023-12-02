import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/views/admin/dashboard/backups/backups_row.dart';

class BackupsTable extends StatelessWidget {
  final ValueNotifier<List<Backup>> backupsNotifier;
  final Function() fetchBackups;

  const BackupsTable({
    Key? key,
    required this.backupsNotifier,
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

  Widget _getHeaderRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _styledTextCell("Delete"),
        ),
        Expanded(
          flex: 2,
          child: _styledTextCell("Timestamp"),
        ),
        Expanded(
          flex: 1,
          child: _styledTextCell("Restore"),
        ),
        Expanded(
          flex: 3,
          child: _styledTextCell("File"),
        ),
        Expanded(
          flex: 1,
          child: _styledTextCell("Download"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: backupsNotifier,
      builder: (context, backups, child) {
        if (backups.isEmpty) {
          return const Center(
            child: Text("No backups found"),
          );
        } else {
          backups = sortBackupsByDate(backups);
          return Column(
            children: [
              // header
              SizedBox(
                height: 50,
                child: _getHeaderRow(),
              ),

              // table
              Expanded(
                child: ListView.builder(
                  itemCount: backups.length,
                  itemBuilder: (context, index) {
                    String name = backups[index].entry;
                    // convert unix timestamp to human readable date
                    String date = parseServerTimestampToString(backups[index].unixTimestamp);

                    return BackupsRow(
                      backupName: name,
                      backupDate: date,
                      fetchBackups: fetchBackups,
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

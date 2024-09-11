import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/shared/dashboard/team_data/td_table_types.dart';
import 'package:tms/views/shared/edit_checkbox.dart';

class ExportTeamDataButton extends StatefulWidget {
  final List<TDColumn> columns;
  final List<TDRow> rows;

  const ExportTeamDataButton({
    Key? key,
    required this.columns,
    required this.rows,
  }) : super(key: key);

  @override
  State<ExportTeamDataButton> createState() => _ExportTeamDataButtonState();
}

class _ExportTeamDataButtonState extends State<ExportTeamDataButton> {
  List<TDColumn> _columns = [];

  @override
  void initState() {
    super.initState();
    _columns = List.from(widget.columns);
  }

  String get csv {
    List<List<String>> csvRows = [];

    List<String> csvHeader = [];
    for (int i = 0; i < _columns.length; i++) {
      if (_columns[i].show) {
        csvHeader.add(_columns[i].label);
      }
    }

    csvRows.add(csvHeader);

    for (TDRow row in widget.rows) {
      List<String> csvRow = [];

      for (int i = 0; i < _columns.length; i++) {
        if (_columns[i].show) {
          csvRow.add(row.cells[i].text);
        }
      }

      csvRows.add(csvRow);
    }

    return const ListToCsvConverter().convert(csvRows);
  }

  void _exportCSV() {
    Uint8List bytes = Uint8List.fromList(csv.codeUnits);

    FileSaver.instance.saveFile(
      name: 'team_data.csv',
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.download, color: Colors.green),
              SizedBox(width: 10),
              Text('Export Options', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              itemCount: _columns.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_columns[index].label),
                      ),
                      EditCheckbox(
                        value: _columns[index].show,
                        onChanged: (value) {
                          setState(() {
                            _columns[index].show = value;
                          });
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exportCSV();
              },
              child: const Text('Export', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
      ),
      onPressed: () {
        _showExportOptions();
      },
      icon: const Icon(Icons.download, size: 18),
      label: const Text('Export'),
    );
  }
}

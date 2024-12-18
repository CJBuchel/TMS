import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class ExportButton extends StatelessWidget {
  final List<List<String>> data;

  const ExportButton({
    Key? key,
    required this.data,
  }) : super(key: key);

  void _onConfirmExport() {
    // create csv data
    String csvContent = data.map((row) {
      return row.map((field) {
        if (field.contains(',') || field.contains('\n') || field.contains('"')) {
          field = field.replaceAll('"', '""');
          return '"$field"';
        }
        return field;
      }).join(",");
    }).join("\n");

    Uint8List csvBytes = Uint8List.fromList(csvContent.codeUnits);

    FileSaver.instance.saveFile(
      name: "team_data",
      bytes: csvBytes,
      ext: "csv",
      mimeType: MimeType.csv,
    );
  }

  void _onExport(BuildContext context) {
    ConfirmDialog(
      style: DialogStyle.info(
        title: "Export Data",
        message: const Text("Export current filtered data?"),
      ),
      onConfirm: () => _onConfirmExport(),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        overlayColor: Colors.green[900],
        shadowColor: Colors.green[900],
        surfaceTintColor: Colors.green[900],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      icon: const Icon(Icons.download),
      label: const Text("Export"),
      onPressed: () => _onExport(context),
    );
  }
}

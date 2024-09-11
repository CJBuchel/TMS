import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/setup/parse_schedule.dart';
import 'package:tuple/tuple.dart';

class CSVImportSetup extends StatelessWidget {
  final void Function(Tuple2<FilePickerResult, SetupRequest>) onSelectedSchedule;

  const CSVImportSetup({
    Key? key,
    required this.onSelectedSchedule,
  }) : super(key: key);

  Future<bool?> showParseError(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                "Error Parsing Schedule",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text("The CSV file you have selected is not valid."),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: Responsive.buttonHeight(context, 1),
        width: Responsive.buttonWidth(context, 1),
        child: ElevatedButton.icon(
          onPressed: () {
            FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['csv', 'txt'],
            ).then((result) {
              if (result != null) {
                // parse the schedule, if it's not valid, pop up dialog
                Tuple2<bool, SetupRequest?> parsed = parseSchedule(result);
                if (parsed.item1 && parsed.item2 != null) {
                  onSelectedSchedule(Tuple2(result, parsed.item2!));
                } else {
                  showParseError(context);
                }
              }
            });
          },
          icon: const Icon(Icons.upload_file),
          label: const Text("Import CSV"),
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/admin/setup/parse_schedule.dart';
import 'package:tms/screens/shared/list_util.dart';

class OfflineSetup extends StatefulWidget {
  const OfflineSetup({Key? key}) : super(key: key);

  @override
  _OfflineSetupState createState() => _OfflineSetupState();
}

class _OfflineSetupState extends State<OfflineSetup> {
  FilePickerResult? _selectedSchedule;
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();

  final List<String> _dropDownSeasons = [
    "2023",
    "2022",
    "2021",
    "2020",
  ];
  String? _selectedSeason;

  Future<bool?> showConfirmPurge(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              Text(
                "Confirm Purge",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text("Are you sure you want to purge the database?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void onClear() {
    _adminPasswordController.clear();
    _eventNameController.clear();
    setState(() {
      _selectedSchedule = null;
      _selectedSeason = _dropDownSeasons[0];
    });
  }

  void onSubmit() {}

  void onPurge() async {
    final shouldPurge = await showConfirmPurge(context);
    if (shouldPurge == true) {
      // @TODO: Purge submit request to purge
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedSeason = _dropDownSeasons[0];
  }

  Widget importCSV() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Text(
            'Import Generated Schedule [MAIN]',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: SizedBox(
            height: Responsive.buttonHeight(context, 1),
            width: Responsive.buttonWidth(context, 1),
            child: ElevatedButton.icon(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv', 'txt'],
                );
                if (result != null) {
                  parseSchedule(result);
                  setState(() {
                    _selectedSchedule = result;
                  });
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Import CSV"),
            ),
          ),
        ),
        if (_selectedSchedule != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Text(
              "Selected: ${_selectedSchedule!.files.single.name}",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Offline Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Steps List
            const NumberedList(title: "", list: [
              "Import CSV",
              "Admin Password",
              "Select Season",
              "Enter Event Name",
              "Submit",
            ]),

            // Import CSV
            importCSV(),

            // Admin Password
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: TextField(
                controller: _adminPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Admin Password',
                  hintText: 'Enter Password, (default: `password`)',
                ),
              ),
            ),

            // Select Season
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Text("Select Season", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: DropdownButton<String>(
                value: _selectedSeason,
                hint: const Text("Select Season"),
                onChanged: (String? value) {
                  setState(() {
                    _selectedSeason = value;
                  });
                },
                items: _dropDownSeasons.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Event Name',
                  hintText: 'Enter Event Name: e.g `Curtin Championship`',
                ),
              ),
            ),

            // Purge
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: Responsive.buttonHeight(context, 1),
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      onPressed: onPurge,
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text(
                        "Purge",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: Responsive.buttonHeight(context, 1),
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                        ),
                        onPressed: onClear,
                        icon: const Icon(Icons.clear, color: Colors.white),
                        label: const Text(
                          "Clear",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: Responsive.buttonHeight(context, 1),
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        onPressed: onSubmit,
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

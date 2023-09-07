import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/admin/setup/parse_schedule.dart';
import 'package:tms/screens/admin/setup/setup.dart';
import 'package:tms/screens/shared/list_util.dart';
import 'package:tuple/tuple.dart';

class OfflineSetup extends StatefulWidget {
  const OfflineSetup({Key? key}) : super(key: key);

  @override
  _OfflineSetupState createState() => _OfflineSetupState();
}

class _OfflineSetupState extends State<OfflineSetup> {
  FilePickerResult? _selectedSchedule;
  SetupRequest? _setupRequest;
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _timerCountdownController = TextEditingController();

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

  Future<bool?> showParseError(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.orange),
              Text(
                "Error Parsing Schedule",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text("The CSV file you have selected is not valid."),
        );
      },
    );
  }

  void onClear() {
    _adminPasswordController.clear();
    _eventNameController.clear();
    _timerCountdownController.clear();
    setState(() {
      _selectedSchedule = null;
      _selectedSeason = _dropDownSeasons[0];
      _timerCountdownController.value = const TextEditingValue(text: "150");
    });
  }

  void onSubmit(BuildContext context) async {
    Event event = Event(
      eventRounds: _setupRequest?.event.eventRounds ?? 3,
      name: _eventNameController.text,
      pods: _setupRequest?.event.pods ?? [],
      season: _selectedSeason ?? "",
      tables: _setupRequest?.event.tables ?? [],
      timerLength: int.parse(_timerCountdownController.text),
    );

    SetupRequest request = SetupRequest(
      authToken: "", // handled by setupRequester
      adminPassword: _adminPasswordController.text,
      event: event,
      judgingSessions: _setupRequest?.judgingSessions ?? [],
      matches: _setupRequest?.matches ?? [],
      teams: _setupRequest?.teams ?? [],
      users: _setupRequest?.users ?? [],
    );

    setupEventRequest(request).then((res) {
      if (res != HttpStatus.ok) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Setup Error"),
            content: SingleChildScrollView(
              child: Text(res == HttpStatus.unauthorized ? "Invalid Authorization" : "Server Error"),
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check, color: Colors.green),
                Text(
                  "Setup Success",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text("The event ${_eventNameController.text} has been successfully setup."),
          ),
        );
      }
    });
  }

  void onPurge() async {
    final shouldPurge = await showConfirmPurge(context);
    if (shouldPurge == true) {
      purgeEventRequest().then((res) {
        if (res != HttpStatus.ok) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Purge Error"),
              content: SingleChildScrollView(
                child: Text(res == HttpStatus.unauthorized ? "Invalid Authorization" : "Server Error"),
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  Text(
                    "Purge Success",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text("The event has successfully been purged"),
            ),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedSeason = _dropDownSeasons[0];
    _timerCountdownController.value = const TextEditingValue(text: "150");
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
              onPressed: () {
                FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv', 'txt'],
                ).then((result) {
                  if (result != null) {
                    // parse the schedule, if it's not valid, pop up dialog
                    Tuple2<bool, SetupRequest?> parsed = parseSchedule(result);
                    if (parsed.item1) {
                      setState(() {
                        _selectedSchedule = result;
                        _setupRequest = parsed.item2;
                      });
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

            Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: TextField(
                  controller: _timerCountdownController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Timer Countdown',
                    hintText: 'Enter Timer Countdown: e.g `150`',
                  ),
                )),

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
                        onPressed: () => onSubmit(context),
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

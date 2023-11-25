import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/setup/offline_setup/admin_password.dart';
import 'package:tms/views/admin/setup/offline_setup/csv_import_setup.dart';
import 'package:tms/views/admin/setup/offline_setup/game_setup.dart';
import 'package:tms/views/admin/setup/offline_setup/setup_buttons/setup_buttons.dart';
import 'package:tms/views/shared/list_util.dart';

class OfflineSetup extends StatefulWidget {
  const OfflineSetup({Key? key}) : super(key: key);

  @override
  State<OfflineSetup> createState() => _OfflineSetupState();
}

class _OfflineSetupState extends State<OfflineSetup> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final TextEditingController _adminPasswordController = TextEditingController();

  Event? _event;
  FilePickerResult? _selectedSchedule;
  SetupRequest? _setupRequest;

  // game setup controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _selectedSeasonController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();
  final TextEditingController _endgameTimerCountdownController = TextEditingController();
  final TextEditingController _timerCountdownController = TextEditingController();

  // backup controllers
  final TextEditingController _backupIntervalController = TextEditingController();
  final TextEditingController _backupCountController = TextEditingController();

  set _setInitialEvent(Event e) {
    if (mounted) {
      setState(() {
        _event = e;
        _eventNameController.text = e.name;
        _roundNumberController.text = e.eventRounds.toString();
        _endgameTimerCountdownController.text = e.endGameTimerLength.toString();
        _timerCountdownController.text = e.timerLength.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _roundNumberController.value = const TextEditingValue(text: "3");
    _endgameTimerCountdownController.value = const TextEditingValue(text: "30");
    _timerCountdownController.value = const TextEditingValue(text: "150");

    onEventUpdate((event) => _setInitialEvent = event);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getEvent().then((event) => _setInitialEvent = event);
    });
  }

  void onClear() {
    _adminPasswordController.clear();
    _eventNameController.clear();
    _timerCountdownController.clear();
    setState(() {
      _selectedSchedule = null;
      _selectedSeasonController.clear();
      _timerCountdownController.value = const TextEditingValue(text: "150");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            const Text(
              'Offline Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // snippet instructions
            const NumberedList(title: "", list: [
              "Import CSV",
              "Admin Password",
              "Select Backup Intervals",
              "Select Season",
              "Enter Event Name",
              "Submit",
            ]),

            // import csv
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 16),
              child: CSVImportSetup(
                onSelectedSchedule: (schedule) {
                  setState(() {
                    _selectedSchedule = schedule.item1;
                    _setupRequest = schedule.item2;
                  });
                },
              ),
            ),
            if (_selectedSchedule != null)
              Text(
                "Selected Schedule: ${_selectedSchedule!.files.single.name}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

            // admin password
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 16),
              child: AdminPasswordSetup(
                adminPasswordController: _adminPasswordController,
              ),
            ),

            // backups

            // game setup
            GameSetup(
              eventNameController: _eventNameController,
              selectedSeasonController: _selectedSeasonController,
              roundNumberController: _roundNumberController,
              endgameTimerCountdownController: _endgameTimerCountdownController,
              timerCountdownController: _timerCountdownController,
            ),

            // submit/buttons
            SetupButtons(
              existingEvent: _event,
              adminPasswordController: _adminPasswordController,
              eventNameController: _eventNameController,
              backupIntervalController: _backupIntervalController,
              backupCountController: _backupCountController,
              selectedSeasonController: _selectedSeasonController,
              roundNumberController: _roundNumberController,
              endgameTimerCountdownController: _endgameTimerCountdownController,
              timerCountdownController: _timerCountdownController,
              setupRequest: _setupRequest,
              onClear: onClear,
            ),
          ],
        ),
      ),
    );
  }
}

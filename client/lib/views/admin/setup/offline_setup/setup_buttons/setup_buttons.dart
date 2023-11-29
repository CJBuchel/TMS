import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/setup/offline_setup/setup_buttons/setup_clear_button.dart';
import 'package:tms/views/admin/setup/offline_setup/setup_buttons/setup_purge_button.dart';
import 'package:tms/views/admin/setup/offline_setup/setup_buttons/setup_submit_button.dart';

class SetupButtons extends StatelessWidget {
  // callbacks
  final Function? onPurge;
  final Function? onClear;
  final Function? onSubmit;

  // main controllers
  final TextEditingController adminPasswordController;
  final TextEditingController eventNameController;
  final TextEditingController backupIntervalController;
  final TextEditingController backupCountController;
  final TextEditingController selectedSeasonController;
  final TextEditingController roundNumberController;
  final TextEditingController endgameTimerCountdownController;
  final TextEditingController timerCountdownController;

  // setup request
  final SetupRequest? setupRequest;
  final Event? existingEvent;

  const SetupButtons({
    Key? key,
    this.onPurge,
    this.onClear,
    this.onSubmit,

    // existing event
    required this.existingEvent,

    // main controllers
    required this.adminPasswordController,
    required this.eventNameController,
    required this.backupIntervalController,
    required this.backupCountController,
    required this.selectedSeasonController,
    required this.roundNumberController,
    required this.endgameTimerCountdownController,
    required this.timerCountdownController,

    // setup request
    this.setupRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Purge
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Row(
            children: [
              Expanded(
                child: SetupPurgeButton(onPurge: onPurge),
              ),
            ],
          ),
        ),

        // clear/submit
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // clear
              Expanded(
                child: SetupClearButton(onClear: onClear),
              ),

              // spacer
              const SizedBox(width: 16),

              // submit
              Expanded(
                child: SetupSubmitButton(
                  onSubmit: onSubmit,

                  // existing event
                  existingEvent: existingEvent,

                  // main controllers
                  adminPasswordController: adminPasswordController,
                  eventNameController: eventNameController,
                  backupIntervalController: backupIntervalController,
                  backupCountController: backupCountController,
                  selectedSeasonController: selectedSeasonController,
                  roundNumberController: roundNumberController,
                  endgameTimerCountdownController: endgameTimerCountdownController,
                  timerCountdownController: timerCountdownController,

                  // setup request
                  setupRequest: setupRequest,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

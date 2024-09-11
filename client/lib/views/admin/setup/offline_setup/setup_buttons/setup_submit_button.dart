import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/event_local_db.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class SetupSubmitButton extends StatelessWidget {
  final Function? onSubmit;
  final Event? existingEvent;

  final TextEditingController adminPasswordController;
  final TextEditingController eventNameController;
  final TextEditingController backupIntervalController;
  final TextEditingController backupCountController;
  final TextEditingController selectedSeasonController;
  final TextEditingController roundNumberController;
  final TextEditingController endgameTimerCountdownController;
  final TextEditingController timerCountdownController;

  final SetupRequest? setupRequest;

  const SetupSubmitButton({
    Key? key,
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

  void _onSubmit(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Event fallbackEvent = existingEvent ?? EventLocalDB.singleDefault();

        Event event = Event(
          name: eventNameController.text,
          backupInterval: int.tryParse(backupIntervalController.text) ?? fallbackEvent.backupInterval,
          backupCount: int.tryParse(backupCountController.text) ?? fallbackEvent.backupCount,
          eventRounds: int.tryParse(roundNumberController.text) ?? fallbackEvent.eventRounds,
          pods: setupRequest?.event?.pods ?? fallbackEvent.pods,
          season: selectedSeasonController.text.isNotEmpty ? selectedSeasonController.text : fallbackEvent.season,
          tables: setupRequest?.event?.tables ?? fallbackEvent.tables,
          endGameTimerLength: int.tryParse(endgameTimerCountdownController.text) ?? fallbackEvent.endGameTimerLength,
          timerLength: int.tryParse(timerCountdownController.text) ?? fallbackEvent.timerLength,
        );

        SetupRequest request = SetupRequest(
          authToken: "", // handled by requester
          adminPassword: adminPasswordController.text,
          event: event,
          judgingSessions: setupRequest?.judgingSessions ?? [],
          matches: setupRequest?.matches ?? [],
          teams: setupRequest?.teams ?? [],
          users: setupRequest?.users ?? [],
        );
        return FutureBuilder(
          future: setupEventRequest(request),
          builder: (context, res) {
            if (res.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text("Submitting..."),
                content: LinearProgressIndicator(),
              );
            } else {
              if (res.data == HttpStatus.ok) {
                onSubmit?.call();
                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      Text(
                        "Setup Success",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Text("The event ${eventNameController.text} has been successfully setup."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              } else {
                // remove this popup and show the network error
                Navigator.pop(context);
                showNetworkError(res.data!, context);
                return const SizedBox.shrink();
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.buttonHeight(context, 1),
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
        ),
        onPressed: () => _onSubmit(context),
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text(
          "Submit",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

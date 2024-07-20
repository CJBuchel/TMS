import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class StartButtons extends StatelessWidget {
  Widget _countdownButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.orange),
        overlayColor: WidgetStateProperty.all(Colors.orange[400]),
        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
      ),
      onPressed: () {
        Provider.of<GameTimerProvider>(context, listen: false).startTimerWithCountdown().then((status) {
          if (status != HttpStatus.ok) {
            SnackBarDialog.fromStatus(message: "Countdown", status: status).show(context);
          }
        });
      },
      icon: const Icon(Icons.timer, size: 40, color: Colors.white),
      label: const Text('Countdown', style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  Widget _startButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green),
        overlayColor: WidgetStateProperty.all(Colors.green[400]),
        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
      ),
      onPressed: () {
        Provider.of<GameTimerProvider>(context, listen: false).startTimer().then((status) {
          if (status != HttpStatus.ok) {
            SnackBarDialog.fromStatus(message: "Start", status: status).show(context);
          }
        });
      },
      icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
      label: const Text('Start', style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 5),
            child: _countdownButton(context),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 10),
            child: _startButton(context),
          ),
        ),
      ],
    );
  }
}

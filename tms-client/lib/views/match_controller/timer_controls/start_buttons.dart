import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

const _inactiveColor = Color(0xFF9E9E9E);
const _backgroundColor = Color(0xFFD55C00);
const _overlayColor = Color(0xFFFF6F00);

class StartButtons extends StatelessWidget {
  final bool active;

  const StartButtons({
    Key? key,
    required this.active,
  }) : super(key: key);

  final WidgetStateProperty<Color?> _inactiveColorState = const WidgetStatePropertyAll(_inactiveColor);
  final WidgetStateProperty<Color?> _backgroundColorState = const WidgetStatePropertyAll(_backgroundColor);
  final WidgetStateProperty<Color?> _overlayColorState = const WidgetStatePropertyAll(_overlayColor);

  Widget _countdownButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: active ? _backgroundColorState : _inactiveColorState,
        overlayColor: active ? _overlayColorState : _inactiveColorState,
        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
      ),
      onPressed: () {
        if (active) {
          Provider.of<GameTimerProvider>(context, listen: false).startTimerWithCountdown().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Countdown", status: status).show(context);
            }
          });
        }
      },
      icon: const Icon(Icons.timer_outlined, size: 40, color: Colors.white),
      label: const Text('Countdown', style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  Widget _startButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: active ? WidgetStateProperty.all(Colors.green) : _inactiveColorState,
        overlayColor: active ? WidgetStateProperty.all(Colors.green[400]) : _inactiveColorState,
        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
      ),
      onPressed: () {
        if (active) {
          Provider.of<GameTimerProvider>(context, listen: false).startTimer().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Start", status: status).show(context);
            }
          });
        }
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

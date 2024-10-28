import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/widgets/buttons/barber_pole_button.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

const _inactiveColor = Color(0xFF9E9E9E);
const _backgroundColor = Colors.red;
const _overlayColor = Colors.redAccent;

class AbortButton extends StatelessWidget {
  const AbortButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),
      child: BarberPoleButton(
        backgroundColor: Colors.grey[800],
        overlayColor: Colors.grey[700],
        stripeColor: _backgroundColor,
        onPressed: () {
          Provider.of<GameTimerProvider>(context, listen: false).stopTimer().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Abort", status: status).show(context);
            }
          });
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.warning, size: 40, color: Colors.white),
            Text('Abort', style: TextStyle(fontSize: 20, color: Colors.white)),
            Icon(Icons.warning, size: 40, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

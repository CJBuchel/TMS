import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/widgets/buttons/barber_pole_button.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

const _inactiveColor = Color(0xFF9E9E9E);
const _backgroundColor = Color(0xFF388E3C);
const _overlayColor = Color(0xFF42A847);

class ReadyMatchButton extends StatelessWidget {
  final WidgetStateProperty<Color?> _inactiveColorState = const WidgetStatePropertyAll(_inactiveColor);
  final WidgetStateProperty<Color?> _backgroundColorState = const WidgetStatePropertyAll(_backgroundColor);
  final WidgetStateProperty<Color?> _overlayColorState = const WidgetStatePropertyAll(_overlayColor);

  Widget _readyButton(BuildContext context, {bool active = true}) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: active ? _backgroundColorState : _inactiveColorState,
        overlayColor: active ? _overlayColorState : _inactiveColorState,
        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
      ),
      onPressed: () {
        if (active) {
          Provider.of<GameMatchProvider>(context, listen: false).readyMatches().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Ready Match", status: status).show(context);
            }
          });
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.check, size: 40, color: Colors.white),
          Text('Ready Match', style: TextStyle(fontSize: 20, color: Colors.white)),
          Icon(Icons.check, size: 40, color: Colors.white),
        ],
      ),
    );
  }

  Widget _unreadyButton(BuildContext context, {bool active = true}) {
    return BarberPoleButton(
      backgroundColor: Colors.grey[800],
      overlayColor: Colors.grey[700],
      stripeColor: active ? _overlayColor : _inactiveColor,
      onPressed: () {
        if (active) {
          Provider.of<GameMatchProvider>(context, listen: false).unreadyMatches().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Unready Match", status: status).show(context);
            }
          });
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.close, size: 40, color: Colors.white),
          Text('Unready Match', style: TextStyle(fontSize: 20, color: Colors.white)),
          Icon(Icons.close, size: 40, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Selector<GameMatchProvider, ({bool canReady, bool canUnready, bool isRunning})>(
      selector: (context, provider) {
        return (
          canReady: provider.canReady,
          canUnready: provider.canUnready,
          isRunning: provider.isMatchesRunning,
        );
      },
      builder: (context, data, _) {
        if (data.canReady) {
          return _readyButton(context);
        } else if (data.canUnready) {
          return _unreadyButton(context);
        } else if (data.isRunning) {
          return _unreadyButton(context, active: false);
        } else {
          return _readyButton(context, active: false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),

      // ready/unready button
      child: _buttons(context),
    );
  }
}

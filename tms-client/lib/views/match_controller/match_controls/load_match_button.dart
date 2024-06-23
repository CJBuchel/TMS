import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/widgets/buttons/barber_pole_button.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class LoadMatchButton extends StatelessWidget {
  final MaterialStateProperty<Color?> _inactiveColor = const MaterialStatePropertyAll(Colors.grey);
  final MaterialStateProperty<Color?> _backgroundColor = const MaterialStatePropertyAll(Color(0xFFD55C00));
  final MaterialStateProperty<Color?> _overlayColor = const MaterialStatePropertyAll(Color(0xFFFF6F00));

  Widget _loadButton(BuildContext context, {bool active = true}) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: active ? _backgroundColor : _inactiveColor,
        overlayColor: active ? _overlayColor : _inactiveColor,
        textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
      ),
      onPressed: () {
        if (active) {
          Provider.of<GameMatchProvider>(context, listen: false).loadMatches().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Load Match", status: status).show(context);
            }
          });
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.expand_more, size: 40, color: Colors.white),
          Text('Load Match', style: TextStyle(fontSize: 20, color: Colors.white)),
          Icon(Icons.expand_more, size: 40, color: Colors.white),
        ],
      ),
    );
  }

  Widget _unloadButton(BuildContext context, {bool active = true}) {
    return BarberPoleButton(
      backgroundColor: Colors.grey[800],
      overlayColor: Colors.grey[700],
      stripeColor: const Color(0xFFD55C00),
      onPressed: () {
        if (active) {
          Provider.of<GameMatchProvider>(context, listen: false).unloadMatches().then((status) {
            if (status != HttpStatus.ok) {
              SnackBarDialog.fromStatus(message: "Unload Match", status: status).show(context);
            }
          });
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.expand_less, size: 40, color: Colors.white),
          Text('Unload Match', style: TextStyle(fontSize: 20, color: Colors.white)),
          Icon(Icons.expand_less, size: 40, color: Colors.white),
        ],
      ),
    );
  }

  // Widget _

  Widget _button(BuildContext context) {
    return Selector<GameMatchProvider, ({bool canLoad, bool canUnload})>(
      selector: (context, provider) {
        return (
          canLoad: provider.canLoad,
          canUnload: provider.canUnload,
        );
      },
      builder: (context, data, _) {
        if (data.canLoad) {
          return _loadButton(context, active: data.canLoad);
        } else if (data.canUnload) {
          return _unloadButton(context, active: data.canUnload);
        } else {
          return _loadButton(context, active: data.canLoad);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),

      // load/unload button
      child: _button(context),
    );
  }
}

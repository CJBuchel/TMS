import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/widgets/buttons/barber_pole_button.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

const _inactiveColor = Color(0xFF9E9E9E);
const _backgroundColor = Color(0xFFD55C00);
const _overlayColor = Color(0xFFFF6F00);

class _MatchStatusData {
  final bool canLoad;
  final bool canUnload;
  final bool canUnready;
  final bool isRunning;

  _MatchStatusData({
    required this.canLoad,
    required this.canUnload,
    required this.canUnready,
    required this.isRunning,
  });
}

class LoadMatchButton extends StatelessWidget {
  final WidgetStateProperty<Color?> _inactiveColorState = const WidgetStatePropertyAll(_inactiveColor);
  final WidgetStateProperty<Color?> _backgroundColorState = const WidgetStatePropertyAll(_backgroundColor);
  final WidgetStateProperty<Color?> _overlayColorState = const WidgetStatePropertyAll(_overlayColor);

  final List<GameMatch> matches;

  const LoadMatchButton({Key? key, required this.matches}) : super(key: key);

  Widget _loadButton(BuildContext context, {bool active = true}) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: active ? _backgroundColorState : _inactiveColorState,
        overlayColor: active ? _overlayColorState : _inactiveColorState,
        textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
      ),
      onPressed: () {
        if (active) {
          Provider.of<GameMatchStatusProvider>(context, listen: false).loadMatches().then((status) {
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
      stripeColor: active ? _backgroundColor : _inactiveColor,
      onPressed: () {
        if (active) {
          Provider.of<GameMatchStatusProvider>(context, listen: false).unloadMatches().then((status) {
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

  // Widget

  Widget _button(BuildContext context) {
    return Selector<GameMatchStatusProvider, _MatchStatusData>(
      selector: (context, statusProvider) {
        return _MatchStatusData(
          canLoad: statusProvider.canLoad(matches),
          canUnload: statusProvider.canUnload,
          canUnready: statusProvider.canUnready,
          isRunning: statusProvider.isMatchesRunning,
        );
      },
      builder: (context, data, _) {
        if (data.canLoad) {
          return _loadButton(context, active: data.canLoad);
        } else if (data.canUnload) {
          return _unloadButton(context, active: data.canUnload);
        } else if (data.canUnready) {
          return _unloadButton(context, active: data.canUnload);
        } else if (data.isRunning) {
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

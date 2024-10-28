import 'package:flutter/material.dart';

enum TableSignalState {
  SIG,
  STANDBY,
  READY,
}

class GameTableStatus extends StatelessWidget {
  final TableSignalState state;
  final AnimationController blinkController;

  const GameTableStatus({
    Key? key,
    required this.state,
    required this.blinkController,
  }) : super(key: key);

  Widget _statusText(TableSignalState state) {
    Color? color = Colors.red;
    String text = "SIG";

    switch (state) {
      case TableSignalState.SIG:
        color = Colors.red;
        text = "SIG";
      case TableSignalState.STANDBY:
        color = const Color(0xFFCE7500);
        text = "STBY";
      case TableSignalState.READY:
        color = Colors.green;
        text = "RDY";
    }

    return AnimatedBuilder(
      animation: blinkController,
      builder: (context, child) {
        Color? status_color = color;
        if (state == TableSignalState.SIG) {
          status_color = blinkController.value < 0.5 ? color : Colors.transparent;
        }

        return Text(
          text,
          style: TextStyle(
            color: status_color,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RepaintBoundary(
        child: _statusText(state),
      ),
    );
  }
}

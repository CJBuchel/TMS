import 'package:flutter/material.dart';

enum TableSignalState {
  SIG,
  STANDBY,
  READY,
}

class GameTableStatus extends StatefulWidget {
  final TableSignalState state;

  const GameTableStatus({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<GameTableStatus> createState() => _GameTableStatusState();
}

class _GameTableStatusState extends State<GameTableStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      animation: _controller,
      builder: (context, child) {
        Color? status_color = color;
        if (state == TableSignalState.SIG) {
          status_color = _controller.value < 0.5 ? color : Colors.transparent;
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
      child: _statusText(widget.state),
    );
  }
}

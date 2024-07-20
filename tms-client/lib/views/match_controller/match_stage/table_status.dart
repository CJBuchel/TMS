import 'package:flutter/material.dart';

enum TableStatusState {
  NO_SIG, // No Signal
  STANDBY, // Standby
  READY, // Ready
}

class TableStatus extends StatefulWidget {
  final String table;

  const TableStatus({
    Key? key,
    required this.table,
  }) : super(key: key);

  @override
  _TableStatusState createState() => _TableStatusState();
}

class _TableStatusState extends State<TableStatus> with SingleTickerProviderStateMixin {
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

  Widget _statusText(TableStatusState state) {
    Color? color = Colors.red;
    String text = "SIG";

    switch (state) {
      case TableStatusState.NO_SIG:
        color = Colors.red;
        text = "SIG";
      case TableStatusState.STANDBY:
        color = const Color(0xFFCE7500);
        text = "STBY";
      case TableStatusState.READY:
        color = Colors.green;
        text = "RDY";
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Color? status_color = color;
        if (state == TableStatusState.NO_SIG) {
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
      child: _statusText(TableStatusState.NO_SIG),
    );
  }
}

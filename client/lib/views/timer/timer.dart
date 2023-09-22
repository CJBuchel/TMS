import 'package:flutter/material.dart';
import 'package:tms/views/shared/tool_bar.dart';
import 'package:tms/views/timer/clock.dart';

class Timer extends StatelessWidget {
  const Timer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Clock
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Clock(),
            ],
          ),
        ],
      ),
    );
  }
}

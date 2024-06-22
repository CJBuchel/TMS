import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_controls/load_match_button.dart';
import 'package:tms/widgets/timers/MatchLiveScheduleTimer.dart';

class MatchControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoadMatchButton(),

        // TTL Timer
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: const Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: MatchLiveScheduleTimer(
                  positiveStyle: TextStyle(
                    color: Colors.green,
                    fontSize: 50,
                    fontFamily: "lcdbold",
                  ),
                  negativeStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 50,
                    fontFamily: "lcdbold",
                  ),
                ),
              ),
            ),
          ),
        ),

        // Ready/Not Ready button
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: const Center(
              child: Text('Ready/Not Ready'),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_controls/load_match_button.dart';
import 'package:tms/views/match_controller/match_controls/ready_match_button.dart';
import 'package:tms/widgets/timers/match_live_schedule_timer.dart';

class MatchControls extends StatelessWidget {
  const MatchControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            // top and bottom border
            border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          child: LoadMatchButton(),
        ),

        // TTL Timer
        const Expanded(
          flex: 1,
          child: Center(
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

        // Ready/Not Ready button
        Container(
          decoration: const BoxDecoration(
            // top and bottom border
            border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          child: ReadyMatchButton(),
        ),
      ],
    );
  }
}

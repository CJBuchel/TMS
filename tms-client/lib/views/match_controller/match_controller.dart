import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_controls/match_controls.dart';
import 'package:tms/views/match_controller/match_selector/match_selection.dart';
import 'package:tms/views/match_controller/match_stage/match_stage.dart';
import 'package:tms/views/match_controller/timer_controls/timer_controls.dart';

class MatchController extends StatelessWidget {
  const MatchController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Column(
            children: [
              // stage
              Expanded(
                flex: 1,
                child: MatchStage(),
              ),

              // match control
              const Expanded(
                flex: 1,
                child: MatchControls(),
              ),

              // timer controls
              const Expanded(
                flex: 1,
                child: TimerControls(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: MatchSelection(),
        ),
      ],
    );
  }
}

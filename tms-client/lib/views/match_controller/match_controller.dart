import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_controls/match_controls.dart';
import 'package:tms/views/match_controller/match_selector/match_selection.dart';
import 'package:tms/views/match_controller/match_stage/match_stage.dart';

class MatchController extends StatelessWidget {
  const MatchController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // stage
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: MatchStage(),
                ),
              ),

              // match control
              Expanded(
                flex: 1,
                child: MatchControls(),
              ),

              // timer controls
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: const Center(
                    child: Text('Timer Controllers'),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 500)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              return MatchSelection();
            },
          ),
        ),
      ],
    );
  }
}

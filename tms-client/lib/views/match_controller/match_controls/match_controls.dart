import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_controls/load_match_button.dart';

class MatchControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Load/Unload button
        // Expanded(
        //   flex: 1,
        //   child: LoadMatchButton(),
        // ),

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
              child: Text('TTL Timer'),
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

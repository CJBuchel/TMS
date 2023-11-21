import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/match_control/controls/controls_mobile.dart';
import 'package:tms/views/match_control/controls/controls_shared.dart';

class MatchControlFloatingButtons extends StatelessWidget {
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<GameMatch> selectedMatches;
  final List<GameMatch> loadedMatches;

  const MatchControlFloatingButtons({
    Key? key,
    required this.teams,
    required this.matches,
    required this.selectedMatches,
    required this.loadedMatches,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoadable = selectedMatches.isNotEmpty && loadedMatches.isEmpty && selectedMatches.every((element) => !element.complete);
    isLoadable = checkCompletedMatchesHaveScores(selectedMatches, matches) ? isLoadable : false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
            heroTag: "load-unload",
            onPressed: () {
              if (loadedMatches.isNotEmpty) {
                loadMatch(MatchLoadStatus.unload, context, selectedMatches).then((value) {
                  if (value != HttpStatus.ok) {
                    displayErrorDialog(value, context);
                  }
                });
              } else if (isLoadable) {
                loadMatch(MatchLoadStatus.load, context, selectedMatches).then((value) {
                  if (value != HttpStatus.ok) {
                    displayErrorDialog(value, context);
                  }
                });
              }
            },
            enableFeedback: true,
            backgroundColor: (isLoadable || loadedMatches.isNotEmpty) ? Colors.orange : Colors.grey,
            child:
                loadedMatches.isEmpty ? const Icon(Icons.arrow_downward, color: Colors.white) : const Icon(Icons.arrow_upward, color: Colors.white)),
        FloatingActionButton(
          heroTag: "next",
          onPressed: () {
            if (selectedMatches.isNotEmpty && loadedMatches.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchControlMobileControls(
                    teams: teams,
                    matches: matches,
                    loadedMatches: loadedMatches,
                    selectedMatches: selectedMatches,
                  ),
                ),
              );
            }
          },
          enableFeedback: true,
          backgroundColor: (selectedMatches.isNotEmpty && loadedMatches.isNotEmpty) ? Colors.blue[300] : Colors.grey,
          child: const Icon(Icons.double_arrow, color: Colors.white),
        ),
      ],
    );
  }
}

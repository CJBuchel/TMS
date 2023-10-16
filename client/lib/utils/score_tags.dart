import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/schema/tms_schema.dart';

class GameScoreTags {
  final TeamGameScore score;
  bool _conflicting = false;

  GameScoreTags({
    Key? key,
    required this.score, // score to check
    required List<TeamGameScore> scores, // all scores
  }) {
    int conflicts = 0;
    // check how many of duplicated rounds there are
    for (var ts in scores) {
      if (ts.scoresheet.round == score.scoresheet.round) {
        conflicts++;
      }
    }

    // if there are more than 1, then there is a conflict
    if (conflicts > 1) {
      _conflicting = true;
    }
  }

  List<Widget> get() {
    List<Widget> tags = [];

    // no show
    if (score.noShow) {
      tags.add(
        Tooltip(
          message: "No Show",
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: const Text("NS", style: TextStyle(color: Colors.orange)),
          ),
        ),
      );
    }

    // cloud publish
    if (score.cloudPublished) {
      tags.add(
        Tooltip(
          message: "Cloud Published",
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyan),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: const Text("CP", style: TextStyle(color: Colors.cyan)),
          ),
        ),
      );
    }

    // conflict
    if (_conflicting) {
      tags.add(
        Tooltip(
          message: "Conflicting scores for Round ${score.scoresheet.round}",
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: const Text("CON", style: TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    return tags;
  }
}

import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/scoring/game_scoring.dart';

class ScoresheetEditPopup {
  final BuildContext context;
  final TeamGameScore gameScore;
  Function(TeamGameScore)? onGameScore;

  ScoresheetEditPopup({
    required this.context,
    required this.gameScore,
    this.onGameScore,
  }) {
    _answers = gameScore.scoresheet.answers;
    _score = gameScore.score;
    _publicComment = gameScore.scoresheet.publicComment;
    _privateComment = gameScore.scoresheet.privateComment;
  }

  List<ScoreAnswer> _answers = [];
  List<ScoreError> _errors = [];
  int _score = 0;
  String _publicComment = "";
  String _privateComment = "";

  Widget _scoresheetDisplay() {
    return GameScoring(
      initialAnswers: gameScore.scoresheet.answers,
      initialPublicComment: gameScore.scoresheet.publicComment,
      initialPrivateComment: gameScore.scoresheet.privateComment,
      onAnswers: (List<ScoreAnswer> answers) {
        _answers = answers;
      },
      onErrors: (List<ScoreError> errors) {
        _errors = errors;
      },
      onPublicCommentChange: (String publicComment) {
        _publicComment = publicComment;
      },
      onPrivateCommentChange: (String privateComment) {
        _privateComment = privateComment;
      },
      onScore: (int score) {
        _score = score;
      },
    );
  }

  Widget _scoresheetContents() {
    return SizedBox(
      width: Responsive.buttonWidth(context, 3.5),
      child: SingleChildScrollView(
        child: _scoresheetDisplay(),
      ),
    );
  }

  void _dialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 10),
              Text("Editing Scoresheet"),
            ],
          ),
          content: _scoresheetContents(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_errors.isEmpty) {
                  String gp = gameScore.gp;
                  gameScore.score = _score;

                  for (var answer in _answers) {
                    if (answer.id == "gp") {
                      gp = answer.answer;
                    }
                  }

                  gameScore.gp = gp;
                  gameScore.scoresheet.answers = _answers;
                  gameScore.scoresheet.privateComment = _privateComment;
                  gameScore.scoresheet.publicComment = _publicComment;

                  Navigator.of(context).pop();
                  onGameScore?.call(gameScore);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void show() => _dialog();
}

import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/scoring/scoresheet_edit_popup.dart';

class EditScoresheet extends StatefulWidget {
  final TeamGameScore gameScore;
  final Function(TeamGameScore)? onGameScore;
  const EditScoresheet({
    Key? key,
    required this.gameScore,
    this.onGameScore,
  }) : super(key: key);

  @override
  State<EditScoresheet> createState() => _EditScoresheetState();
}

class _EditScoresheetState extends State<EditScoresheet> {
  int _score = 0;

  set _setScore(int score) {
    if (mounted) {
      setState(() {
        _score = score;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setScore = widget.gameScore.score;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text("Score: "),
            Text(
              "$_score",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            ScoresheetEditPopup(
              context: context,
              gameScore: widget.gameScore,
              onGameScore: (gs) {
                setState(() {
                  _setScore = gs.score;
                });
                widget.onGameScore?.call(gs);
              },
            ).show();
          },
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

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
  String _publicComment = "";
  String _privateComment = "";

  set _setScore(int score) {
    if (mounted) {
      setState(() {
        _score = score;
      });
    }
  }

  set _setPublicComment(String publicComment) {
    if (mounted) {
      setState(() {
        _publicComment = publicComment;
      });
    }
  }

  set _setPrivateComment(String privateComment) {
    if (mounted) {
      setState(() {
        _privateComment = privateComment;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setPublicComment = widget.gameScore.scoresheet.publicComment;
    _setPrivateComment = widget.gameScore.scoresheet.privateComment;
    _setScore = widget.gameScore.score;
  }

  Widget _publicCommentDisplay() {
    return Row(
      children: [
        const Text("Public Comment: "),
        Text(
          _publicComment,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _privateCommentDisplay() {
    return Row(
      children: [
        const Text("Private Comment: "),
        Text(
          _privateComment,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _scoreEdit() {
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
                  _setPublicComment = gs.scoresheet.publicComment;
                  _setPrivateComment = gs.scoresheet.privateComment;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _publicCommentDisplay(),
        _privateCommentDisplay(),
        _scoreEdit(),
      ],
    );
  }
}

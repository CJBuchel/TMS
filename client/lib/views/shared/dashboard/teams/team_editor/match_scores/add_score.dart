import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/match_scores/edit_scoresheet.dart';
import 'package:tms/views/shared/edit_checkbox.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddScore extends StatefulWidget {
  final Team team;
  final Function()? onAdd;

  const AddScore({
    Key? key,
    required this.team,
    this.onAdd,
  }) : super(key: key);

  @override
  State<AddScore> createState() => _AddScoreState();
}

class _AddScoreState extends State<AddScore> {
  final TextEditingController _roundController = TextEditingController();
  TeamGameScore? _gameScore;

  set _setGameScore(TeamGameScore gs) {
    if (mounted) {
      setState(() {
        _gameScore = gs;
      });
    }
  }

  set _setNoShow(bool ns) {
    if (_gameScore != null) {
      TeamGameScore gs = _gameScore!;
      gs.noShow = ns;
      _setGameScore = gs;
    }
  }

  set _setCloudPublished(bool cp) {
    if (_gameScore != null) {
      TeamGameScore gs = _gameScore!;
      gs.cloudPublished = cp;
      _setGameScore = gs;
    }
  }

  void _setInitial() {
    // create default game score
    NetworkAuth().getUser().then((user) {
      final scoresheet = GameScoresheet(
        answers: [],
        privateComment: "",
        publicComment: "",
        round: 0,
        teamId: "",
        tournamentId: "",
      );

      _setGameScore = TeamGameScore(
        cloudPublished: false,
        noShow: false,
        gp: "",
        referee: user.username,
        score: 0,
        scoresheet: scoresheet,
        timeStamp: 0,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _setInitial();
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Error",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            )
          ],
        );
      }),
    );
  }

  Widget _paddedInner(Widget inner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: inner,
    );
  }

  void _addScore() {
    if (_gameScore != null) {
      postTeamGameScoresheetRequest(widget.team.teamNumber, _gameScore!).then((value) {
        if (value != HttpStatus.ok) {
          showNetworkError(value, context, subMessage: "Error adding score");
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Added score for team ${widget.team.teamNumber}"),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onAdd?.call();
        _setInitial();
      });
    }
  }

  Widget _content() {
    if (_gameScore != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // round
          _paddedInner(
            TextField(
              controller: _roundController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: "Round",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (_gameScore != null) {
                  TeamGameScore gs = _gameScore!;
                  gs.scoresheet.round = int.tryParse(value) ?? 0;
                  _setGameScore = gs;
                }
              },
            ),
          ),

          // no show
          _paddedInner(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("No Show"),
                EditCheckbox(
                  value: _gameScore?.noShow ?? false,
                  onChanged: (ns) => _setNoShow = ns,
                ),
              ],
            ),
          ),

          // cloud published
          _paddedInner(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cloud Published"),
                EditCheckbox(
                  value: _gameScore?.cloudPublished ?? false,
                  onChanged: (cp) => _setCloudPublished = cp,
                ),
              ],
            ),
          ),

          _paddedInner(
            EditScoresheet(
              gameScore: _gameScore!,
              onGameScore: (gs) {
                _setGameScore = gs;
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _addScoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add, color: Colors.green),
              SizedBox(width: 10),
              Text("Add Score"),
            ],
          ),
          content: _content(),
          actions: [
            // cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setInitial();
              },
              child: const Text("Cancel"),
            ),

            // add button
            TextButton(
              onPressed: () {
                if (_roundController.text.isEmpty) {
                  showError("Round cannot be empty");
                } else {
                  Navigator.of(context).pop();
                  _addScore();
                }
              },
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _addScoreDialog();
      },
      icon: const Icon(
        Icons.add,
        color: Colors.green,
      ),
    );
  }
}

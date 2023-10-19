import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/match_scores/edit_scoresheet.dart';
import 'package:tms/views/shared/edit_checkbox.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditScoreDialog extends StatefulWidget {
  final Team team;
  final int index;
  final Function()? onUpdate;
  const EditScoreDialog({
    Key? key,
    required this.team,
    required this.index,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<EditScoreDialog> createState() => _EditScoreDialogState();
}

class _EditScoreDialogState extends State<EditScoreDialog> {
  final TextEditingController _roundController = TextEditingController();
  final TextEditingController _refereeController = TextEditingController();
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

  TeamGameScore get _getGameScoreCopy {
    var jsonStr = widget.team.gameScores[widget.index].toJson();
    return TeamGameScore.fromJson(jsonStr);
  }

  void _setInitial() {
    _setGameScore = _getGameScoreCopy;
    _roundController.text = _gameScore?.scoresheet.round.toString() ?? "";
    _refereeController.text = _gameScore?.referee ?? "";
  }

  @override
  void initState() {
    super.initState();
    _setInitial();
  }

  Widget _paddedInner(Widget inner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: inner,
    );
  }

  void _updateScore() {
    final updatedTeam = widget.team;
    if (_gameScore != null) {
      updatedTeam.gameScores[widget.index] = _gameScore!;
      updateTeamRequest(widget.team.teamNumber, updatedTeam).then((res) {
        if (res != HttpStatus.ok) {
          showNetworkError(res, context, subMessage: "Error updating score at index ${widget.index}");
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Updated score for team ${widget.team.teamNumber}"),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onUpdate?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameScore == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 10),
            Text("Editing Score"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // round number
            _paddedInner(
              TextField(
                // only allow number
                controller: _roundController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Round Number",
                ),

                onChanged: (v) {
                  if (_gameScore != null) {
                    TeamGameScore gs = _gameScore!;
                    gs.scoresheet.round = int.tryParse(v) ?? 0;
                    _setGameScore = gs;
                  }
                },
              ),
            ),

            // referee
            _paddedInner(
              TextField(
                controller: _refereeController,
                decoration: const InputDecoration(
                  labelText: "Referee",
                ),
                onChanged: (v) {
                  if (_gameScore != null) {
                    TeamGameScore gs = _gameScore!;
                    gs.referee = v;
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
                  EditCheckbox(value: _gameScore?.noShow ?? false, onChanged: (ns) => _setNoShow = ns),
                ],
              ),
            ),

            // cloud published
            _paddedInner(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Cloud Published"),
                  EditCheckbox(value: _gameScore?.cloudPublished ?? false, onChanged: (cp) => _setCloudPublished = cp),
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
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _setInitial();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateScore();
            },
            child: const Text("Update", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }
  }
}

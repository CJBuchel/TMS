import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit/edit_match_checkbox.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit/edit_time.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditMatch extends StatefulWidget {
  final String matchNumber;

  const EditMatch({Key? key, required this.matchNumber}) : super(key: key);

  @override
  State<EditMatch> createState() => _EditMatchState();
}

class _EditMatchState extends State<EditMatch> {
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // edits
  late GameMatch _updatedMatch;

  Future<void> _getMatch() async {
    await getMatchRequest(widget.matchNumber).then((res) {
      if (res.item1 != HttpStatus.ok) {
        showNetworkError(res.item1, context, subMessage: "Failed to get match");
      } else {
        if (res.item2 != null) {
          if (mounted) {
            GameMatch m = res.item2!;
            setState(() {
              _updatedMatch = m;

              _matchNumberController.text = m.matchNumber;
              _roundNumberController.text = m.roundNumber.toString();
              _startTimeController.text = m.startTime;
            });
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getMatch();
  }

  void _updateMatch() {
    _updatedMatch.matchNumber = _matchNumberController.text;
    _updatedMatch.roundNumber = int.parse(_roundNumberController.text);
    _updatedMatch.startTime = _startTimeController.text;
    _updatedMatch.endTime = _endTimeController.text;

    updateMatchRequest(widget.matchNumber, _updatedMatch).then((res) {
      if (res != HttpStatus.ok) {
        showNetworkError(res, context, subMessage: "Failed to update match");
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated ${widget.matchNumber}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Widget _editMatchNumber() {
    return TextField(
      controller: _matchNumberController,
      decoration: const InputDecoration(
        labelText: "Match Number",
      ),
    );
  }

  Widget _editRoundNumber() {
    return TextField(
      controller: _roundNumberController,
      // allow only numbers
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Round Number",
      ),
    );
  }

  Widget _checkboxContainer(String label, bool initialValue, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          MatchCheckbox(
            value: initialValue,
            onChanged: (value) => onChanged(value),
          )
        ],
      ),
    );
  }

  void _editMatchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.blue),
                  Text(" Editing Match ${widget.matchNumber}"),
                ],
              ),
              content: SizedBox(
                // width: constraints.maxWidth * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _editMatchNumber(),
                      _editRoundNumber(),
                      EditTime(
                        label: "Start Time",
                        controller: _startTimeController,
                        initialTime: _updatedMatch.startTime,
                      ),
                      EditTime(
                        label: "End Time",
                        controller: _endTimeController,
                        initialTime: _updatedMatch.endTime,
                      ),
                      _checkboxContainer("Complete", _updatedMatch.complete, (value) {
                        if (mounted) {
                          setState(() {
                            _updatedMatch.complete = value;
                          });
                        }
                      }),
                      _checkboxContainer("Deferred", _updatedMatch.gameMatchDeferred, (value) {
                        if (mounted) {
                          setState(() {
                            _updatedMatch.gameMatchDeferred = value;
                          });
                        }
                      }),
                      _checkboxContainer("Exhibition", _updatedMatch.exhibitionMatch, (value) {
                        if (mounted) {
                          setState(() {
                            _updatedMatch.exhibitionMatch = value;
                          });
                        }
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    _updateMatch();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Update", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _getMatch();
        _editMatchDialog();
      },
      icon: const Icon(Icons.edit, color: Colors.orange),
    );
  }
}

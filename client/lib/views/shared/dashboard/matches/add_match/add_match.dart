import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/matches/add_match/round_number.dart';
import 'package:tms/views/shared/dashboard/matches/add_match/start_time.dart';
import 'package:tms/views/shared/edit_time.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddMatch extends StatelessWidget {
  final List<GameMatch> matches;
  AddMatch({
    Key? key,
    required this.matches,
  }) : super(key: key);

  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final ValueNotifier<bool> _isExhibition = ValueNotifier<bool>(false);

  void _addMatch(BuildContext context) {
    final GameMatch match = GameMatch(
      // default fields
      complete: false,
      gameMatchDeferred: false,
      matchTables: [],

      // edited fields
      matchNumber: _matchNumberController.text,
      roundNumber: int.tryParse(_roundNumberController.text) ?? 1,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      exhibitionMatch: _isExhibition.value,
    );

    addMatchRequest(match).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Match added"),
          ),
        );
      }
    });
  }

  Widget _editMatchNumber() {
    return TextFormField(
      controller: _matchNumberController,
      decoration: const InputDecoration(
        labelText: "Match Number",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _editRoundNumber() {
    return RoundNumber(
      isExhibition: _isExhibition,
      controller: _roundNumberController,
    );
  }

  Widget _editStartTime() {
    return MatchStartTime(
      matches: matches,
      controller: _startTimeController,
      onProposedMatchNumber: (value) {
        _matchNumberController.text = value;
      },
      onProposedEndTime: (value) {
        _endTimeController.text = value;
      },
    );
  }

  Widget _editEndTime() {
    return EditTime(
      controller: _endTimeController,
      label: "End Time",
    );
  }

  Widget _rowPadding(Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: widget,
    );
  }

  void _addMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add, color: Colors.green),
              SizedBox(width: 10),
              Text("Add Match"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _rowPadding(_editStartTime()),
                _rowPadding(_editEndTime()),
                _rowPadding(_editRoundNumber()),
                _rowPadding(_editMatchNumber()),
              ],
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
                if (_roundNumberController.text.isNotEmpty && _matchNumberController.text.isNotEmpty) {
                  _addMatch(context);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add, color: Colors.green),
      onPressed: () {
        _addMatchDialog(context);
      },
    );
  }
}

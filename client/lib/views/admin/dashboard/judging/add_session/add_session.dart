import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/judging/add_session/start_time.dart';
import 'package:tms/views/shared/edit_time.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddSession extends StatelessWidget {
  final List<JudgingSession> sessions;

  AddSession({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  final TextEditingController _sessionNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  Widget _editStartTime() {
    return JudgingStartTime(
      sessions: sessions,
      controller: _startTimeController,
      onProposedSessionNumber: (value) {
        _sessionNumberController.text = value;
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

  Widget _editSessionNumber() {
    return TextFormField(
      controller: _sessionNumberController,
      decoration: const InputDecoration(
        labelText: "Session Number",
        border: OutlineInputBorder(),
      ),
    );
  }

  void _addSession(BuildContext context) {
    final JudgingSession session = JudgingSession(
      // default fields
      complete: false,
      judgingSessionDeferred: false,
      judgingPods: [],

      // edited fields
      sessionNumber: _sessionNumberController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
    );

    addJudgingSessionRequest(session).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Session added"),
          ),
        );
      }
    });
  }

  Widget _rowPadding(Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: widget,
    );
  }

  void _addSessionDialog(BuildContext context) {
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
                _rowPadding(_editSessionNumber()),
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
                if (_sessionNumberController.text.isNotEmpty) {
                  _addSession(context);
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
        _addSessionDialog(context);
      },
    );
  }
}

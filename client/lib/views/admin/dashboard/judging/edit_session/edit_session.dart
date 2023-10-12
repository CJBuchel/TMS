import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/edit_checkbox.dart';
import 'package:tms/views/shared/edit_time.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditSession extends StatefulWidget {
  final String sessionNumber;
  final Function()? onEdit;
  const EditSession({Key? key, required this.sessionNumber, this.onEdit}) : super(key: key);

  @override
  State<EditSession> createState() => _EditSessionState();
}

class _EditSessionState extends State<EditSession> {
  final TextEditingController _sessionNumberController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // edits
  JudgingSession _updatedSession = JudgingSession(
    sessionNumber: "",
    startTime: "",
    endTime: "",
    complete: false,
    judgingSessionDeferred: false,
    judgingPods: [],
  );

  Future<void> _getSession() async {
    await getJudgingSessionRequest(widget.sessionNumber).then((res) {
      if (res.item1 != HttpStatus.ok) {
        showNetworkError(res.item1, context, subMessage: "Failed to get session");
      } else {
        if (res.item2 != null) {
          if (mounted) {
            JudgingSession s = res.item2!;
            setState(() {
              _updatedSession = s;

              _sessionNumberController.text = s.sessionNumber;
              _startTimeController.text = s.startTime;
              _endTimeController.text = s.endTime;
            });
          }
        }
      }
    });
  }

  void _updateSession() {
    _updatedSession.sessionNumber = _sessionNumberController.text;
    _updatedSession.startTime = _startTimeController.text;
    _updatedSession.endTime = _endTimeController.text;

    updateJudgingSessionRequest(widget.sessionNumber, _updatedSession).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error updating session");
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated session ${_updatedSession.sessionNumber}"),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onEdit?.call();
    });
  }

  Widget _editSessionNumber() {
    return TextField(
      controller: _sessionNumberController,
      decoration: const InputDecoration(
        labelText: "Session Number",
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
          EditCheckbox(
            value: initialValue,
            onChanged: (value) => onChanged(value),
          ),
        ],
      ),
    );
  }

  void _editSessionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              Text(" Editing Session ${_updatedSession.sessionNumber}"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _editSessionNumber(),
                EditTime(
                  label: "Start Time",
                  controller: _startTimeController,
                  initialTime: _updatedSession.startTime,
                ),
                EditTime(
                  label: "End Time",
                  controller: _endTimeController,
                  initialTime: _updatedSession.endTime,
                ),
                _checkboxContainer("Complete", _updatedSession.complete, (value) {
                  if (mounted) {
                    setState(() {
                      _updatedSession.complete = value;
                    });
                  }
                }),
                _checkboxContainer("Deferred", _updatedSession.judgingSessionDeferred, (value) {
                  if (mounted) {
                    setState(() {
                      _updatedSession.judgingSessionDeferred = value;
                    });
                  }
                }),
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
                _updateSession();
                Navigator.of(context).pop();
              },
              child: const Text("Update", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _getSession();
        _editSessionDialog();
      },
      icon: const Icon(Icons.edit, color: Colors.orange),
    );
  }
}

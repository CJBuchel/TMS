import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/judging/pods/pods_table.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditPods extends StatefulWidget {
  final String sessionNumber;
  final List<Team> teams;

  const EditPods({Key? key, required this.sessionNumber, required this.teams}) : super(key: key);

  @override
  State<EditPods> createState() => _EditPodsState();
}

class _EditPodsState extends State<EditPods> {
  JudgingSession _session = JudgingSession(
    sessionNumber: "",
    startTime: "",
    endTime: "",
    complete: false,
    judgingSessionDeferred: false,
    judgingPods: [],
  );

  void _updateSession() {
    updateJudgingSessionRequest(widget.sessionNumber, _session).then((res) {
      if (res != HttpStatus.ok) {
        showNetworkError(res, context, subMessage: "Failed to update session");
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text("Session ${widget.sessionNumber} updated"),
        ));
      }
    });
  }

  void _setSession(JudgingSession session) {
    if (mounted) {
      setState(() {
        _session = session;
      });
    }
  }

  Future<void> _getSession() async {
    await getJudgingSessionRequest(widget.sessionNumber).then((res) {
      if (res.item1 != HttpStatus.ok) {
        showNetworkError(res.item1, context, subMessage: "Failed to get session");
      } else {
        if (res.item2 != null) {
          JudgingSession s = res.item2!;
          _setSession(s);
        }
      }
    });
  }

  void _editPodsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(builder: (context, constraints) {
          double width = (Responsive.isMobile(context) || Responsive.isTablet(context)) ? constraints.maxWidth * 0.9 : constraints.maxWidth * 0.5;
          double height = (Responsive.isMobile(context) || Responsive.isTablet(context)) ? constraints.maxHeight * 0.9 : constraints.maxHeight * 0.5;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit, color: Colors.pink),
                Text(" Editing Pods For Match ${widget.sessionNumber}"),
              ],
            ),
            content: SizedBox(
              height: height,
              width: width,
              child: PodTable(
                session: _session,
                teams: widget.teams,
                onSessionUpdate: (session) {
                  _setSession(session);
                },
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
                child: const Text("Update", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.pink),
      onPressed: () async {
        await _getSession();
        _editPodsDialog();
      },
    );
  }
}

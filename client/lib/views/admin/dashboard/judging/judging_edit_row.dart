import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/judging/edit_session/delete_session.dart';
import 'package:tms/views/admin/dashboard/judging/edit_session/edit_session.dart';
import 'package:tms/views/admin/dashboard/judging/pods/edit_pods.dart';

class JudgingEditRow extends StatelessWidget {
  final JudgingSession session;
  final List<Team> teams;
  final Color rowColor;

  const JudgingEditRow({
    Key? key,
    required this.session,
    required this.teams,
    required this.rowColor,
  }) : super(key: key);

  Widget _styledTextCell(String label, {Color? color, Color? textColor}) {
    return Container(
      color: color,
      child: Center(
          child: Text(
        label,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      )),
    );
  }

  Widget _styledCell(Widget inner, {Color? color}) {
    return Container(
      color: color,
      child: Center(
        child: inner,
      ),
    );
  }

  Widget _getPodRow(List<JudgingPod> pods, {Color? color}) {
    List<Widget> podRows = [];

    for (var pod in pods) {
      podRows.add(
        Expanded(
          flex: 1,
          child: _styledTextCell(
            pod.pod,
            color: session.complete && !pod.scoreSubmitted
                ? Colors.red
                : pod.scoreSubmitted
                    ? Colors.green
                    : color,
          ),
        ),
      );

      podRows.add(
        Expanded(
          flex: 1,
          child: _styledTextCell(
            pod.teamNumber,
            color: session.complete && !pod.scoreSubmitted
                ? Colors.red
                : pod.scoreSubmitted
                    ? Colors.green
                    : color,
          ),
        ),
      );
    }

    return Row(
      children: podRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // delete button
          Expanded(
            flex: 1,
            child: _styledCell(DeleteSession(sessionNumber: session.sessionNumber)),
          ),

          // session number
          Expanded(
            flex: 1,
            child: _styledTextCell(session.sessionNumber, color: rowColor),
          ),

          // session time
          Expanded(
            flex: 2,
            child: _styledTextCell(session.startTime, color: rowColor),
          ),

          // edit match
          Expanded(
            flex: 1,
            child: _styledCell(EditSession(sessionNumber: session.sessionNumber)),
          ),

          // pods info
          if (!Responsive.isMobile(context))
            Expanded(
              flex: 10,
              child: _getPodRow(session.judgingPods, color: rowColor),
            ),

          // edit the pods
          Expanded(
            flex: 1,
            child: _styledCell(EditPods(
              sessionNumber: session.sessionNumber,
              teams: teams,
            )),
          ),
        ],
      ),
    );
  }
}

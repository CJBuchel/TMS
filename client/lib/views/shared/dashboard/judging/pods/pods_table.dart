import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/judging/pods/pod_score_submitted_checkbox.dart';
import 'package:tms/views/shared/dropdowns/drop_down_pod.dart';
import 'package:tms/views/shared/dropdowns/drop_down_team.dart';

class PodTable extends StatefulWidget {
  final JudgingSession session;
  final List<Team> teams;
  final Function(JudgingSession) onSessionUpdate;

  const PodTable({
    Key? key,
    required this.session,
    required this.teams,
    required this.onSessionUpdate,
  }) : super(key: key);

  @override
  State<PodTable> createState() => _PodTableState();
}

class _PodTableState extends State<PodTable> {
  Widget _styledHeader(String content) {
    return Center(child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  DataRow2 _styledRow(JudgingPod pod) {
    return DataRow2(
      cells: [
        // delete button
        DataCell(
          Center(
            child: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                final index = widget.session.judgingPods.indexWhere((p) => p.pod == pod.pod);
                if (index != -1) {
                  JudgingSession updatedSession = widget.session;
                  setState(() {
                    updatedSession.judgingPods.removeAt(index);
                    widget.onSessionUpdate(updatedSession);
                  });
                }
              },
            ),
          ),
        ),

        // pod cell
        DataCell(
          Center(
            child: DropdownPod(
              pod: pod,
              session: widget.session,
              onPodUpdate: (p) {
                widget.onSessionUpdate(p);
              },
            ),
          ),
        ),

        // team cell
        DataCell(
          Center(
            child: DropdownTeam(
              teams: widget.teams,
              session: widget.session,
              pod: pod,
              onPodUpdate: (p) {
                widget.onSessionUpdate(p);
              },
            ),
          ),
        ),

        // submit cell
        DataCell(
          Center(
            child: PodScoreSubmittedCheckbox(
              pod: pod,
              session: widget.session,
              onPodUpdate: (p) {
                widget.onSessionUpdate(p);
              },
            ),
          ),
        ),
      ],
    );
  }

  List<DataRow2> _getRows() {
    List<DataRow2> rows = widget.session.judgingPods.map((e) => _styledRow(e)).toList();

    rows.add(
      DataRow2(cells: [
        DataCell(
          Center(
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                // add on table
                JudgingSession updatedSession = widget.session;
                setState(() {
                  updatedSession.judgingPods.add(
                    JudgingPod(
                      pod: "",
                      scoreSubmitted: false,
                      teamNumber: "",
                    ),
                  );
                  // widget.onMatchUpdate(updatedMatch);
                });
              },
            ),
          ),
        ),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
      ]),
    );

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
        return Colors.transparent;
      }),
      columnSpacing: 10,
      columns: [
        const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S), // delete button]
        DataColumn2(label: _styledHeader("Pod"), size: ColumnSize.L),
        DataColumn2(label: _styledHeader("Team"), size: ColumnSize.L),
        DataColumn2(label: _styledHeader("Submitted"), size: ColumnSize.S),
      ],
      rows: _getRows(),
    );
  }
}

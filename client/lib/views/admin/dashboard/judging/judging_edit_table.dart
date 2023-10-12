import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/judging/add_session/add_session.dart';
import 'package:tms/views/admin/dashboard/judging/judging_edit_row.dart';

class JudgingEditTable extends StatefulWidget {
  final List<JudgingSession> sessions;
  final List<Team> teams;
  final Function() requestJudgingSessions;

  const JudgingEditTable({
    Key? key,
    required this.sessions,
    required this.teams,
    required this.requestJudgingSessions,
  }) : super(key: key);

  @override
  State<JudgingEditTable> createState() => _JudgingEditTableState();
}

class _JudgingEditTableState extends State<JudgingEditTable> {
  List<JudgingSession> _filteredSessions = [];

  void setFilteredSessions(List<JudgingSession> sessions) {
    if (mounted) {
      setState(() {
        _filteredSessions = sessions;
      });
    }
  }

  void _applyFilter() {
    List<JudgingSession> sessions = widget.sessions;
    setFilteredSessions(sessions);
  }

  @override
  void didUpdateWidget(covariant JudgingEditTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      _applyFilter();
    }
  }

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  Widget _getTable() {
    return ListView.builder(
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        bool isDeferred = _filteredSessions[index].judgingSessionDeferred;
        bool isComplete = _filteredSessions[index].complete;

        Color rowColor = Colors.transparent;

        if (isDeferred) {
          rowColor = Colors.cyan;
        } else if (index.isEven) {
          if (isComplete) {
            rowColor = Colors.green;
          } else {
            rowColor = Theme.of(context).splashColor;
          }
        } else {
          if (isComplete) {
            rowColor = Colors.green[300] ?? Colors.green;
          } else {
            rowColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
          }
        }

        return JudgingEditRow(
          session: _filteredSessions[index],
          teams: widget.teams,
          rowColor: rowColor,
        );
      },
    );
  }

  Widget _topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            widget.requestJudgingSessions();
          },
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),
        AddSession(sessions: widget.sessions),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          // top buttons
          SizedBox(
            height: 50,
            child: _topButtons(),
          ),

          // filters
          SizedBox(
            height: 30,
            width: constraints.maxWidth * 0.9,
            child: SizedBox.shrink(),
          ),

          // main table
          Expanded(
            child: SizedBox(
              width: constraints.maxWidth * 0.9,
              child: _getTable(),
            ),
          ),
        ],
      );
    });
  }
}

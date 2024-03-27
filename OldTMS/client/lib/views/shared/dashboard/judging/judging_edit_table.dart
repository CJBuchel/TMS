import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/judging/add_session/add_session.dart';
import 'package:tms/views/shared/dashboard/judging/judging_edit_row.dart';

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
  String sessionNumberFilter = '';
  String timeFilter = '';
  String podFilter = '';
  String teamFilter = '';

  void setSessionNumberFilter(String m) {
    if (mounted) {
      setState(() {
        sessionNumberFilter = m;
      });
    }
  }

  void setTimeFilter(String t) {
    if (mounted) {
      setState(() {
        timeFilter = t;
      });
    }
  }

  void setPodFilter(String t) {
    if (mounted) {
      setState(() {
        podFilter = t;
      });
    }
  }

  void setTeamFilter(String t) {
    if (mounted) {
      setState(() {
        teamFilter = t;
      });
    }
  }

  void setFilteredSessions(List<JudgingSession> sessions) {
    if (mounted) {
      setState(() {
        _filteredSessions = sessions;
      });
    }
  }

  void _applyFilter() {
    List<JudgingSession> sessions = widget.sessions;

    if (sessionNumberFilter.isNotEmpty) {
      sessions = sessions.where((s) => s.sessionNumber == sessionNumberFilter).toList();
    }

    if (timeFilter.isNotEmpty) {
      sessions = sessions.where((s) => s.startTime.contains(timeFilter)).toList();
    }

    if (podFilter.isNotEmpty) {
      sessions = sessions.where((session) {
        bool found = false;
        for (var pod in session.judgingPods) {
          if (pod.pod.contains(podFilter)) {
            found = true;
            break;
          }
        }
        return found;
      }).toList();
    }

    if (teamFilter.isNotEmpty) {
      sessions = sessions.where((session) {
        bool found = false;
        for (var pod in session.judgingPods) {
          Team? team;
          for (var t in widget.teams) {
            if (t.teamNumber == pod.teamNumber) {
              team = t;
              break;
            }
          }

          String teamNumber = pod.teamNumber.toLowerCase();
          String teamName = team?.teamName.toLowerCase() ?? '';
          // check for team number and team name
          if (teamNumber.contains(teamFilter.toLowerCase()) || teamName.contains(teamFilter.toLowerCase())) {
            found = true;
            break;
          }
        }
        return found;
      }).toList();
    }

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

  Widget filterSessionNumber() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Session Number",
      ),
      onChanged: (s) {
        setSessionNumberFilter(s);
        _applyFilter();
      },
    );
  }

  Widget filterTime() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Time",
      ),
      onChanged: (s) {
        setTimeFilter(s);
        _applyFilter();
      },
    );
  }

  Widget filterPod() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Pod",
      ),
      onChanged: (s) {
        setPodFilter(s);
        _applyFilter();
      },
    );
  }

  Widget filterTeam() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Team",
      ),
      onChanged: (s) {
        setTeamFilter(s);
        _applyFilter();
      },
    );
  }

  Widget _getFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(flex: 1, child: filterSessionNumber()),
        Expanded(flex: 2, child: filterTime()),
        const Expanded(flex: 1, child: SizedBox.shrink()),
        if (!Responsive.isMobile(context))
          Expanded(
            flex: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(flex: 1, child: filterPod()),
                Expanded(flex: 1, child: filterTeam()),
              ],
            ),
          ),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
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
            child: _getFilters(),
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

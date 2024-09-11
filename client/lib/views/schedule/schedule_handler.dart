import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/schedule/judging_schedule.dart';
import 'package:tms/views/schedule/match_schedule.dart';

class ScheduleHandler extends StatefulWidget {
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<JudgingSession> sessions;

  const ScheduleHandler({
    Key? key,
    required this.teams,
    required this.matches,
    required this.sessions,
  }) : super(key: key);

  @override
  State<ScheduleHandler> createState() => _ScheduleHandlerState();
}

class _ScheduleHandlerState extends State<ScheduleHandler> {
  List<GameMatch> _filteredMatches = [];
  List<JudgingSession> _filteredSessions = [];

  bool _matchSchedule = true;

  void _setMatchSchedule(bool schedule) {
    if (mounted) {
      setState(() {
        _matchSchedule = schedule;
      });
    }
  }

  String _numberFilter = '';
  String _teamFilter = '';
  String _startTimeFilter = '';
  String _podTableFilter = '';

  set _setTeamFilter(String t) {
    if (mounted) {
      setState(() {
        _teamFilter = t;
      });
    }
  }

  set _setNumberFilter(String n) {
    if (mounted) {
      setState(() {
        _numberFilter = n;
      });
    }
  }

  set _setStartTimeFilter(String s) {
    if (mounted) {
      setState(() {
        _startTimeFilter = s;
      });
    }
  }

  set _setPodTableFilter(String p) {
    if (mounted) {
      setState(() {
        _podTableFilter = p;
      });
    }
  }

  void _applyFilters() {
    List<GameMatch> filteredMatches = widget.matches;
    List<JudgingSession> filteredSessions = widget.sessions;

    // check for number filters
    if (_numberFilter.isNotEmpty) {
      filteredMatches = filteredMatches.where((element) => element.matchNumber.toString().contains(_numberFilter)).toList();
      filteredSessions = filteredSessions.where((element) => element.sessionNumber.toString().contains(_numberFilter)).toList();
    }

    // teamNumber filter
    if (_teamFilter.isNotEmpty) {
      filteredMatches = filteredMatches.where((element) {
        for (OnTable table in element.matchTables) {
          if (table.teamNumber == _teamFilter) {
            return true;
          }
        }

        return false;
      }).toList();

      filteredSessions = filteredSessions.where((element) {
        for (JudgingPod team in element.judgingPods) {
          if (team.teamNumber == _teamFilter) {
            return true;
          }
        }

        return false;
      }).toList();
    }

    // start time filter
    if (_startTimeFilter.isNotEmpty) {
      filteredMatches = filteredMatches.where((element) => element.startTime.contains(_startTimeFilter)).toList();
      filteredSessions = filteredSessions.where((element) => element.startTime.contains(_startTimeFilter)).toList();
    }

    // pod table filter
    if (_podTableFilter.isNotEmpty) {
      filteredMatches = filteredMatches.where((element) {
        for (OnTable table in element.matchTables) {
          if (table.table.toLowerCase().contains(_podTableFilter.toLowerCase())) {
            return true;
          }
        }

        return false;
      }).toList();

      filteredSessions = filteredSessions.where((element) {
        for (JudgingPod team in element.judgingPods) {
          if (team.pod.toLowerCase().contains(_podTableFilter.toLowerCase())) {
            return true;
          }
        }

        return false;
      }).toList();
    }

    if (mounted) {
      setState(() {
        _filteredMatches = filteredMatches;
        _filteredSessions = filteredSessions;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ScheduleHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyFilters();
  }

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            decoration: BoxDecoration(
              color: _matchSchedule ? Colors.blueGrey : Colors.blueGrey[800],
              border: Border.all(
                color: Colors.blueGrey,
                width: 2,
              ),
            ),
            child: InkWell(
              child: const Center(
                child: Text(
                  "Match Schedule",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                _setMatchSchedule(true);
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            decoration: BoxDecoration(
              color: _matchSchedule ? Colors.blueGrey[800] : Colors.blueGrey,
              border: Border.all(
                color: Colors.blueGrey,
                width: 2,
              ),
            ),
            child: InkWell(
              child: const Center(
                child: Text(
                  "Judging Schedule",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () {
                _setMatchSchedule(false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterTeam() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Team Number",
      ),
      onChanged: (t) {
        _setTeamFilter = t;
        _applyFilters();
      },
    );
  }

  Widget _filterNumber() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Session/Match Number",
      ),
      onChanged: (n) {
        _setNumberFilter = n;
        _applyFilters();
      },
    );
  }

  Widget _filterStartTime() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Start Time",
      ),
      onChanged: (s) {
        _setStartTimeFilter = s;
        _applyFilters();
      },
    );
  }

  Widget _filterPodTable() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Pod/Table",
      ),
      onChanged: (p) {
        _setPodTableFilter = p;
        _applyFilters();
      },
    );
  }

  Widget _filters() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _filterNumber(),
        ),
        Expanded(
          flex: 1,
          child: _filterStartTime(),
        ),
        Expanded(
          flex: 1,
          child: _filterTeam(),
        ),
        Expanded(
          flex: 1,
          child: _filterPodTable(),
        ),
      ],
    );
  }

  Widget _schedule() {
    if (_matchSchedule) {
      return MatchSchedule(teams: widget.teams, matches: _filteredMatches);
    } else {
      return JudgingSchedule(teams: widget.teams, sessions: _filteredSessions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: _header(),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: _filters(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: _schedule(),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/views/admin/dashboard/teams/team_select/team_select_table.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class TeamSelect extends StatefulWidget {
  final Function(String) onTeamSelected;

  const TeamSelect({
    Key? key,
    required this.onTeamSelected,
  }) : super(key: key);

  @override
  State<TeamSelect> createState() => _TeamSelectState();
}

class _TeamSelectState extends State<TeamSelect> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  List<Team> _teams = [];
  List<Team> _filteredTeams = [];
  String _rankFilter = '';
  String _teamFilter = '';

  set _setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

  set _setTeams(List<Team> value) {
    if (mounted) {
      setState(() {
        _teams = sortTeamsByNumber(value);
      });
    }
  }

  set _setTeam(Team value) {
    if (mounted) {
      // find team if exists
      final index = _teams.indexWhere((t) => t.teamNumber == value.teamNumber);
      if (index != -1) {
        setState(() {
          _teams[index] = value;
        });
      } else {
        setState(() {
          _teams.add(value);
        });
      }
    }
  }

  void _fetchTeams() {
    getTeamsRequest().then((value) {
      if (value.item1 != HttpStatus.ok) {
        showNetworkError(value.item1, context, subMessage: "Failed to fetch teams");
      } else {
        _setTeams = value.item2;
        _applyFilters();
      }
    });
  }

  void setRankFilter(String r) {
    if (mounted) {
      setState(() {
        _rankFilter = r;
      });
    }
  }

  void _setTeamFilter(String t) {
    if (mounted) {
      setState(() {
        _teamFilter = t;
      });
    }
  }

  void _setFilteredTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _filteredTeams = teams;
      });
    }
  }

  void _applyFilters() {
    List<Team> filteredTeams = _teams;

    if (_rankFilter.isNotEmpty) {
      filteredTeams = filteredTeams.where((element) => element.ranking.toString().contains(_rankFilter)).toList();
    }

    if (_teamFilter.isNotEmpty) {
      String teamFilter = _teamFilter.toLowerCase();
      filteredTeams = filteredTeams.where((t) {
        return t.teamName.toLowerCase().contains(teamFilter) || t.teamNumber.toString().contains(teamFilter);
      }).toList();
    }

    _setFilteredTeams(filteredTeams);
  }

  @override
  void initState() {
    super.initState();
    onTeamsUpdate((t) {
      _setTeams = t;
      _applyFilters();
    });

    onTeamUpdate((t) {
      _setTeam = t;
      _applyFilters();
    });

    onEventUpdate((e) {
      _setEvent = e;
    });
  }

  Widget _filterRank() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Rank',
      ),
      onChanged: (r) {
        setRankFilter(r);
        _applyFilters();
      },
    );
  }

  Widget _filterTeam() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Team',
      ),
      onChanged: (t) {
        _setTeamFilter(t);
        _applyFilters();
      },
    );
  }

  Widget _getFilters() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _filterRank(),
        ),
        Expanded(
          flex: 3,
          child: _filterTeam(),
        ),
      ],
    );
  }

  Widget _topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            _fetchTeams();
          },
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),

        // add match
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.add,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: 50,
              child: _topButtons(),
            ),
            SizedBox(
              height: 30,
              child: _getFilters(),
            ),
            Expanded(
              child: TeamSelectTable(
                event: _event,
                teams: _filteredTeams,
                onTeamSelected: (t) => widget.onTeamSelected(t),
              ),
            ),
          ],
        );
      },
    );
  }
}

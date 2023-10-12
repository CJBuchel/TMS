import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class TeamSelect extends StatefulWidget {
  final List<Team> teams;
  final Function(Team) onTeamSelected;
  final Function() requestTeams;

  const TeamSelect({
    Key? key,
    required this.teams,
    required this.onTeamSelected,
    required this.requestTeams,
  }) : super(key: key);

  @override
  State<TeamSelect> createState() => _TeamSelectState();
}

class _TeamSelectState extends State<TeamSelect> {
  List<Team> _filteredTeams = [];
  String _rankFilter = '';
  String _teamFilter = '';

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
    List<Team> filteredTeams = widget.teams;

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
  void didUpdateWidget(covariant TeamSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      _applyFilters();
    }
  }

  @override
  void initState() {
    super.initState();
    _applyFilters();
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
          flex: 2,
          child: _filterTeam(),
        ),
      ],
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

  Widget _styledTextCell(String label, {Color? color, Color? textColor}) {
    return _styledCell(
      color: color,
      Text(
        label,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _getRow(Team t, {Color? color}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _styledTextCell(t.ranking.toString(), color: color),
        ),
        Expanded(
          flex: 2,
          child: _styledTextCell("${t.teamNumber} | ${t.teamName}", color: color),
        ),
      ],
    );
  }

  Widget _getTable() {
    return ListView.builder(
      itemCount: _filteredTeams.length,
      itemBuilder: (context, index) {
        Color rowColor = Colors.transparent; // default

        if (index.isEven) {
          rowColor = Theme.of(context).splashColor;
        } else {
          rowColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
        }

        return Container(
          color: rowColor,
          height: 50,
          child: _getRow(_filteredTeams[index], color: rowColor),
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
            widget.requestTeams();
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
              child: _getTable(),
            ),
          ],
        );
      },
    );
  }
}

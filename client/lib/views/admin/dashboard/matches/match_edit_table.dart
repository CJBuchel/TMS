import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/add_match/add_match.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit_row.dart';

class MatchEditTable extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final Function() requestMatches;

  const MatchEditTable({
    Key? key,
    required this.matches,
    required this.teams,
    required this.requestMatches,
  }) : super(key: key);

  @override
  State<MatchEditTable> createState() => _MatchEditTableState();
}

class _MatchEditTableState extends State<MatchEditTable> {
  List<GameMatch> _filteredMatches = [];
  String matchNumberFilter = '';
  String roundNumberFilter = '';
  String tableTeamFilter = '';

  void setMatchNumberFilter(String m) {
    if (mounted) {
      setState(() {
        matchNumberFilter = m;
      });
    }
  }

  void setRoundNumberFilter(String r) {
    if (mounted) {
      setState(() {
        roundNumberFilter = r;
      });
    }
  }

  void setTableTeamFilter(String t) {
    if (mounted) {
      setState(() {
        tableTeamFilter = t;
      });
    }
  }

  void setFilteredMatches(List<GameMatch> matches) {
    if (mounted) {
      setState(() {
        _filteredMatches = matches;
      });
    }
  }

  void _applyFilter() {
    List<GameMatch> matches = widget.matches;

    if (matchNumberFilter.isNotEmpty) {
      matches = matches.where((match) => match.matchNumber == matchNumberFilter).toList();
    }

    if (roundNumberFilter.isNotEmpty) {
      matches = matches.where((match) => match.roundNumber == int.parse(roundNumberFilter)).toList();
    }

    if (tableTeamFilter.isNotEmpty) {
      matches = matches.where((match) {
        bool found = false;
        for (var table in match.matchTables) {
          // check for team number and table name
          if (table.teamNumber.contains(tableTeamFilter) || table.table.toLowerCase().contains(tableTeamFilter.toLowerCase())) {
            found = true;
            break;
          }
        }
        return found;
      }).toList();
    }

    setFilteredMatches(matches);
  }

  @override
  void didUpdateWidget(covariant MatchEditTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      setFilteredMatches(widget.matches);
      _applyFilter();
    }
  }

  @override
  void initState() {
    super.initState();
    setFilteredMatches(widget.matches);
    _applyFilter();
  }

  Widget _topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            widget.requestMatches();
          },
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),

        // add match
        AddMatch(matches: widget.matches),
      ],
    );
  }

  Widget filterMatchNumber() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Match Number',
      ),
      onChanged: (value) {
        setMatchNumberFilter(value);
        _applyFilter();
      },
    );
  }

  Widget filterRoundNumber() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Round Number',
      ),
      onChanged: (value) {
        setRoundNumberFilter(value);
        _applyFilter();
      },
    );
  }

  Widget filterTableTeam() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Table/Team',
      ),
      onChanged: (value) {
        setTableTeamFilter(value);
        _applyFilter();
      },
    );
  }

  Widget getFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // warnings
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(flex: 1, child: filterMatchNumber()),
        Expanded(flex: 1, child: filterRoundNumber()),
        const Expanded(flex: 2, child: SizedBox.shrink()),
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(flex: 2, child: filterTableTeam()),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _getTable() {
    // list view table
    return ListView.builder(
      itemCount: _filteredMatches.length,
      itemBuilder: (context, index) {
        bool isDeferred = _filteredMatches[index].gameMatchDeferred;
        bool isComplete = _filteredMatches[index].complete;

        Color rowColor = Colors.transparent; // default

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

        return MatchEditRow(
          match: _filteredMatches[index],
          teams: widget.teams,
          rowColor: rowColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        children: [
          SizedBox(
            height: 50,
            child: _topButtons(),
          ),

          SizedBox(
            height: 30,
            width: constraints.maxWidth * 0.9,
            child: getFilters(),
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
    }));
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class DropdownTeam extends StatefulWidget {
  final OnTable onTable;
  final GameMatch match;
  final List<Team> teams;
  final Function(GameMatch) onTableUpdate;

  const DropdownTeam({
    Key? key,
    required this.onTable,
    required this.match,
    required this.teams,
    required this.onTableUpdate,
  }) : super(key: key);

  @override
  State<DropdownTeam> createState() => _DropdownTeamState();
}

class _DropdownTeamState extends State<DropdownTeam> {
  final List<Team> _teamOptions = [];

  void _setTeamOptions() {
    _teamOptions.clear();
    List<String> currentTeams = widget.match.matchTables.map((e) => e.teamNumber).toList();

    for (var team in widget.teams) {
      if (!currentTeams.contains(team.teamNumber)) {
        _teamOptions.add(team);
      }
    }
  }

  void setTeamOptions() {
    if (mounted) {
      setState(() {
        _setTeamOptions();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setTeamOptions();
  }

  Widget dropdownTeamSearch() {
    Team? selectedItem;

    if (_teamOptions.isNotEmpty && widget.teams.isNotEmpty) {
      for (var team in widget.teams) {
        if (team.teamNumber == widget.onTable.teamNumber) {
          selectedItem = team;
        }
      }
    }

    return DropdownSearch<Team>(
      popupProps: const PopupProps.menu(
        showSearchBox: true,
      ),
      items: _teamOptions,
      itemAsString: (item) => "${item.teamNumber} | ${item.teamName}",
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Team",
          hintText: "Select Team",
        ),
      ),
      onChanged: (s) {
        if (s != null) {
          final index = widget.match.matchTables.indexWhere((t) => t.teamNumber == widget.onTable.teamNumber);
          if (index != -1) {
            GameMatch updatedMatch = widget.match;
            setState(() {
              updatedMatch.matchTables[index].teamNumber = _teamOptions.firstWhere((e) => e == s).teamNumber;
              widget.onTableUpdate(updatedMatch);
            });
          }
        }
      },
      selectedItem: selectedItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return dropdownTeamSearch();
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class DropdownTeam extends StatefulWidget {
  final List<Team> teams;
  final GameMatch? match;
  final JudgingSession? session;
  final OnTable? onTable;
  final JudgingPod? pod;
  final Function(GameMatch)? onTableUpdate;
  final Function(JudgingSession)? onPodUpdate;

  const DropdownTeam({
    Key? key,
    required this.teams,
    this.onTable,
    this.pod,
    this.session,
    this.match,
    this.onTableUpdate,
    this.onPodUpdate,
  }) : super(key: key);

  @override
  State<DropdownTeam> createState() => _DropdownTeamState();
}

class _DropdownTeamState extends State<DropdownTeam> {
  final List<Team> _teamOptions = [];

  void _setTeamOptions() {
    _teamOptions.clear();
    List<String> currentTeams = [];
    if (widget.match != null) {
      widget.match?.matchTables.map((e) => e.teamNumber).toList();
    } else if (widget.session != null) {
      widget.session?.judgingPods.map((e) => e.teamNumber).toList();
    }

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
        if (widget.onTable != null) {
          if (team.teamNumber == widget.onTable!.teamNumber) {
            selectedItem = team;
          }
        } else if (widget.pod != null) {
          if (team.teamNumber == widget.pod!.teamNumber) {
            selectedItem = team;
          }
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
          int index = -1;
          if (widget.match != null) {
            index = widget.match!.matchTables.indexWhere((t) => t.teamNumber == widget.onTable?.teamNumber);
          } else if (widget.session != null) {
            index = widget.session!.judgingPods.indexWhere((t) => t.teamNumber == widget.pod?.teamNumber);
          }
          if (index != -1) {
            if (widget.match != null) {
              GameMatch updatedMatch = widget.match!;
              setState(() {
                updatedMatch.matchTables[index].teamNumber = _teamOptions.firstWhere((e) => e == s).teamNumber;
                widget.onTableUpdate?.call(updatedMatch);
              });
            } else if (widget.session != null) {
              JudgingSession updatedSession = widget.session!;
              setState(() {
                updatedSession.judgingPods[index].teamNumber = _teamOptions.firstWhere((e) => e == s).teamNumber;
                widget.onPodUpdate?.call(updatedSession);
              });
            }
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

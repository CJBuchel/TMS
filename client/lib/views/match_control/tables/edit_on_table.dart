import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';

class OnTableEdit extends StatefulWidget {
  final List<Team> teams;
  final List<GameMatch> selectedMatches;
  final GameMatch match;
  final OnTable onTable;

  const OnTableEdit({
    Key? key,
    required this.teams,
    required this.selectedMatches,
    required this.match,
    required this.onTable,
  }) : super(key: key);

  @override
  State<OnTableEdit> createState() => _OnTableEditState();
}

class _OnTableEditState extends State<OnTableEdit> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  final List<String> _tableOptions = [];
  final List<Team> _teamsOptions = [];
  OnTable? _onTable;

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
      setTableOptions();
    }
  }

  void _setTableOptions() {
    if (_event != null) {
      _tableOptions.clear();

      List<String> currentTables = widget.selectedMatches.map((match) {
        return match.matchTables.map((e) => e.table).toList();
      }).expand((element) {
        return element;
      }).toList();

      for (var table in _event!.tables) {
        // add only tables which are not in the current match
        if (!currentTables.contains(table)) {
          _tableOptions.add(table);
        }
      }
    }
  }

  void setTableOptions() {
    if (mounted) {
      setState(() {
        _setTableOptions();
      });
    }
  }

  void _setTeamsOptions() {
    _teamsOptions.clear();
    List<String> currentTeams = widget.selectedMatches.map((match) {
      return match.matchTables.map((e) => e.teamNumber).toList();
    }).expand((element) {
      return element;
    }).toList();

    for (var team in widget.teams) {
      // add only teams which are not in the current match
      if (!currentTeams.contains(team.teamNumber)) {
        _teamsOptions.add(team);
      }
    }
  }

  void setTeamOptions() {
    if (mounted) {
      setState(() {
        _setTeamsOptions();
      });
    }
  }

  @override
  void didUpdateWidget(covariant OnTableEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      setTableOptions();
      setTeamOptions();
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) => setEvent(event));

    _onTable = widget.onTable; // default

    _setTeamsOptions();
    _setTableOptions();

    // delay 1 second, get event
    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getEvent().then((event) => setEvent(event));
        setTeamOptions();
      }
    });
  }

  Widget dropdownTableSearch() {
    return DropdownSearch<String>(
      popupProps: const PopupProps.menu(
        showSelectedItems: true,
      ),
      items: _tableOptions,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Table",
          hintText: "Select Table",
        ),
      ),
      onChanged: (s) {
        if (s != null) {
          setState(() {
            _onTable?.table = s;
          });
        }
      },
      selectedItem: _onTable?.table ?? "",
    );
  }

  Widget dropdownTeamSearch() {
    Team? selectedItem;

    if (_teamsOptions.isNotEmpty && widget.teams.isNotEmpty) {
      for (var team in widget.teams) {
        if (team.teamNumber == _onTable?.teamNumber) {
          selectedItem = team;
        }
      }
    }

    return DropdownSearch<Team>(
      popupProps: const PopupProps.menu(
        showSearchBox: true,
      ),
      items: _teamsOptions,
      itemAsString: (item) => "${item.teamNumber} | ${item.teamName}",
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Team",
          hintText: "Select Team",
        ),
      ),
      onChanged: (s) {
        if (s != null) {
          setState(() {
            _onTable?.teamNumber = _teamsOptions.firstWhere((e) => e == s).teamNumber;
          });
        }
      },
      selectedItem: selectedItem,
    );
  }

  void displayErrorDialog(int serverRes, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Bad Request"),
        content: SingleChildScrollView(
          child: Text(serverRes == HttpStatus.unauthorized ? "Invalid User Permissions" : "Server Error $serverRes"),
        ),
      ),
    );
  }

  Future<int> sendUpdate() async {
    int statusCode = HttpStatus.ok;
    if (_onTable != null) {
      // update on table
      GameMatch updatedMatch = widget.match;
      int tableIdx = updatedMatch.matchTables.indexOf(_onTable!);
      updatedMatch.matchTables[tableIdx] = _onTable!;
      int res = await updateMatchRequest(widget.match.matchNumber, updatedMatch);
      if (res != HttpStatus.ok) {
        statusCode = res;
      }
    }

    return statusCode;
  }

  void _editDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text("Editing Table for Match ${widget.match.matchNumber}")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // selector for tables
              Padding(padding: const EdgeInsets.all(10), child: dropdownTableSearch()),
              // selector for teams
              Padding(padding: const EdgeInsets.all(10), child: dropdownTeamSearch()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // update table
                sendUpdate().then((statusCode) {
                  if (statusCode != HttpStatus.ok) {
                    displayErrorDialog(statusCode, context);
                  }
                  Navigator.of(context).pop(true);
                });
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () => _editDialog(),
    );
  }
}

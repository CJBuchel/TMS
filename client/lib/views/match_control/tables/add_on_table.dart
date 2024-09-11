import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';

class OnTableAdd extends StatefulWidget {
  final List<Team> teams;
  final List<GameMatch> selectedMatches;

  const OnTableAdd({
    Key? key,
    required this.teams,
    required this.selectedMatches,
  }) : super(key: key);

  @override
  State<OnTableAdd> createState() => _OnTableAddState();
}

class _OnTableAddState extends State<OnTableAdd> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  GameMatch? _selectedMatch;
  OnTable? _onTable;
  Event? _event;
  final List<String> _tableOptions = [];
  final List<Team> _teamsOptions = [];

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

  void _setTeamOptions() {
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
        _setTeamOptions();
      });
    }
  }

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
      setTableOptions();
    }
  }

  void setSelectedMatch({GameMatch? match}) {
    if (mounted) {
      setState(() {
        _selectedMatch = match ?? (widget.selectedMatches.isNotEmpty ? widget.selectedMatches.first : null);
      });
    }
  }

  @override
  void didUpdateWidget(covariant OnTableAdd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      setTableOptions();
      setTeamOptions();
      setSelectedMatch();
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) => setEvent(event));

    _onTable = OnTable(scoreSubmitted: false, table: "", teamNumber: "");

    _setTeamOptions();
    _setTableOptions();
    setSelectedMatch();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await Network().isConnected()) {
        getEvent().then((event) => setEvent(event));
        setSelectedMatch();
        setTeamOptions();
      }
    });
  }

  Widget dropdownMatchSearch() {
    return DropdownSearch<GameMatch>(
      items: widget.selectedMatches,
      itemAsString: (item) => item.matchNumber,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Match",
          hintText: "Select match to add to",
        ),
      ),
      onChanged: (s) {
        if (s != null) {
          setSelectedMatch(match: s);
        }
      },
      selectedItem: _selectedMatch,
    );
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
            _onTable?.teamNumber = s.teamNumber;
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
    if (_onTable != null && _selectedMatch != null) {
      // update on table
      GameMatch updatedMatch = _selectedMatch!;
      updatedMatch.matchTables.add(_onTable!);
      int res = await updateMatchRequest(_selectedMatch!.matchNumber, updatedMatch);
      if (res != HttpStatus.ok) {
        statusCode = res;
      }
    }

    return statusCode;
  }

  void _addDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.green),
                SizedBox(width: 10),
                Text("Add to match?"),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                dropdownMatchSearch(),
                dropdownTableSearch(),
                dropdownTeamSearch(),
              ],
            ),
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
                if (_onTable?.table != "" && _onTable?.teamNumber != "") {
                  // update table
                  sendUpdate().then((statusCode) {
                    if (statusCode != HttpStatus.ok) {
                      displayErrorDialog(statusCode, context);
                    }
                  });
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.green),
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
      icon: const Icon(Icons.add, color: Colors.green),
      onPressed: () => _addDialog(),
    );
  }
}

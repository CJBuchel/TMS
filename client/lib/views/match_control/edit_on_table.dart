import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

class OnTableEdit extends StatefulWidget {
  final List<Team> teams;
  final OnTable onTable;
  final String matchNumber;

  const OnTableEdit({
    Key? key,
    required this.teams,
    required this.onTable,
    required this.matchNumber,
  }) : super(key: key);

  @override
  State<OnTableEdit> createState() => _OnTableEditState();
}

class _OnTableEditState extends State<OnTableEdit> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  List<Tuple2<String, Team>> _teamsOptions = [];
  OnTable? _onTable;

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) => setEvent(event));

    _onTable = widget.onTable; // default

    // add team options
    for (var team in widget.teams) {
      _teamsOptions.add(Tuple2("${team.teamNumber} | ${team.teamName}", team));
    }

    // delay 1 second, get event
    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) getEvent().then((event) => setEvent(event));
    });
  }

  Widget dropdownTableSearch() {
    return DropdownSearch<String>(
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        disabledItemFn: (String s) => s.startsWith('I'),
      ),
      items: _event?.tables ?? [],
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Table",
          hintText: "Select Table",
        ),
      ),
      onChanged: print,
      selectedItem: _onTable?.table ?? "",
    );
  }

  void _editDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editing Match ${widget.matchNumber}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // selector for tables
              Row(
                children: [
                  Expanded(
                    child: dropdownTableSearch(),
                  ),
                ],
              ),

              // selector for teams
              Row(
                children: [
                  // Expanded(
                  //   child: dropdownTableSearch(),
                  // ),
                ],
              ),
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
                Navigator.of(context).pop(true);
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

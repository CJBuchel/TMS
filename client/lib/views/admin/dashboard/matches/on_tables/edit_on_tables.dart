import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/on_tables/on_tables.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditOnTables extends StatefulWidget {
  final String matchNumber;
  final List<Team> teams;

  const EditOnTables({Key? key, required this.matchNumber, required this.teams}) : super(key: key);

  @override
  State<EditOnTables> createState() => _EditOnTablesState();
}

class _EditOnTablesState extends State<EditOnTables> {
  late GameMatch _match;

  void _updateMatch() {
    updateMatchRequest(widget.matchNumber, _match).then((res) {
      if (res != HttpStatus.ok) {
        showNetworkError(res, context, subMessage: "Failed to update match");
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text("Match ${widget.matchNumber} updated"),
        ));
      }
    });
  }

  void _setMatch(GameMatch m) {
    if (mounted) {
      setState(() {
        _match = m;
      });
    }
  }

  Future<void> _getMatch() async {
    await getMatchRequest(widget.matchNumber).then((res) {
      if (res.item1 != HttpStatus.ok) {
        showNetworkError(res.item1, context, subMessage: "Failed to get match");
      } else {
        if (res.item2 != null) {
          GameMatch m = res.item2!;
          _setMatch(m);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getMatch();
  }

  void _editOnTabledDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: ((context, constraints) {
            double width = (Responsive.isMobile(context) || Responsive.isTablet(context)) ? constraints.maxWidth * 0.9 : constraints.maxWidth * 0.5;
            double height =
                (Responsive.isMobile(context) || Responsive.isTablet(context)) ? constraints.maxHeight * 0.9 : constraints.maxHeight * 0.5;

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.pink),
                  Text("Editing Tables For Match ${widget.matchNumber}"),
                ],
              ),
              content: SizedBox(
                height: height,
                width: width,
                child: OnTables(
                  teams: widget.teams,
                  match: _match,
                  onMatchUpdate: (match) {
                    _setMatch(match);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    _updateMatch();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Update", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.pink),
      onPressed: () async {
        await _getMatch();
        _editOnTabledDialog();
      },
    );
  }
}

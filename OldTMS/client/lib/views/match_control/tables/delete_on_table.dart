import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';

class DeleteOnTable extends StatelessWidget {
  final OnTable onTable;
  final GameMatch match;

  const DeleteOnTable({
    Key? key,
    required this.onTable,
    required this.match,
  }) : super(key: key);

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
    // update on table
    GameMatch updatedMatch = match;
    int tableIdx = updatedMatch.matchTables.indexOf(onTable);
    updatedMatch.matchTables.removeAt(tableIdx);
    int res = await updateMatchRequest(match.matchNumber, updatedMatch);
    if (res != HttpStatus.ok) {
      statusCode = res;
    }

    return statusCode;
  }

  void _deleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 10),
                Text("Remove from match?"),
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
                // update table
                sendUpdate().then((statusCode) {
                  if (statusCode != HttpStatus.ok) {
                    displayErrorDialog(statusCode, context);
                  }
                });
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
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _deleteDialog(context),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditTableButton extends StatelessWidget {
  final String table;
  final Event event;

  EditTableButton({
    Key? key,
    required this.table,
    required this.event,
  }) : super(key: key) {
    _controller.text = table;
  }

  final TextEditingController _controller = TextEditingController();

  void _setTable(BuildContext context) {
    event.tables.remove(table);
    event.tables.add(_controller.text);
    setEventRequest(event).then((res) {
      if (res == HttpStatus.ok) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Table $table updated"),
          ),
        );
      } else {
        showNetworkError(res, context);
      }
    });
  }

  void _editTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.edit,
                color: Colors.orange,
              ),
              SizedBox(width: 10),
              Text("Edit Table", style: TextStyle(color: Colors.orange)),
            ],
          ),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Table Name",
              hintText: "Table Name",
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
                Navigator.of(context).pop();
                _setTable(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _editTableDialog(context),
      icon: const Icon(
        Icons.edit,
        color: Colors.orange,
      ),
    );
  }
}

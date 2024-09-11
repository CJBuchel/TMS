import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddPodButton extends StatelessWidget {
  final Event event;

  AddPodButton({
    Key? key,
    required this.event,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  void _setPod(BuildContext context) {
    var pod = _controller.text;
    event.pods.add(pod);
    setEventRequest(event).then((res) {
      if (res == HttpStatus.ok) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Pod $pod Added"),
          ),
        );
      } else {
        showNetworkError(res, context);
      }
    });
  }

  void _addPodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text("Add Pod", style: TextStyle(color: Colors.green)),
            ],
          ),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Pod Name",
              hintText: "Pod Name",
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
                _setPod(context);
              },
              child: const Text("Add", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _addPodDialog(context),
      icon: const Icon(
        Icons.add,
        color: Colors.green,
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditPodButton extends StatelessWidget {
  final String pod;
  final Event event;

  EditPodButton({
    Key? key,
    required this.pod,
    required this.event,
  }) : super(key: key) {
    _controller.text = pod;
  }

  final TextEditingController _controller = TextEditingController();

  void _setPod(BuildContext context) {
    event.pods.remove(pod);
    event.pods.add(_controller.text);
    setEventRequest(event).then((res) {
      if (res == HttpStatus.ok) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Pod $pod updated"),
          ),
        );
      } else {
        showNetworkError(res, context);
      }
    });
  }

  void _editPodDialog(BuildContext context) {
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
              Text("Edit Pod", style: TextStyle(color: Colors.orange)),
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
      onPressed: () => _editPodDialog(context),
      icon: const Icon(
        Icons.edit,
        color: Colors.orange,
      ),
    );
  }
}

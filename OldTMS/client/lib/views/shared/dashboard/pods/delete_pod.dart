import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeletePodButton extends StatelessWidget {
  final Event event;
  final String pod;

  const DeletePodButton({
    Key? key,
    required this.event,
    required this.pod,
  }) : super(key: key);

  void _deletePod(BuildContext context) {
    event.pods.remove(pod);
    setEventRequest(event).then((res) {
      if (res == HttpStatus.ok) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Pod $pod deleted"),
          ),
        );
      } else {
        showNetworkError(res, context);
      }
    });
  }

  void _deletePodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text("Delete Pod", style: TextStyle(color: Colors.red)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to delete this pod?"),
              SizedBox(height: 10),
              Text("This does not remove the pod from existing sessions"),
            ],
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
                _deletePod(context);
              },
              child: const Text(
                "Delete",
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
      onPressed: () => _deletePodDialog(context),
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
    );
  }
}

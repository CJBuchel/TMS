import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class SetupPurgeButton extends StatelessWidget {
  final Function? onPurge;

  const SetupPurgeButton({
    Key? key,
    this.onPurge,
  }) : super(key: key);

  Future<bool?> showConfirmPurge(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Confirm Purge",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text("Are you sure you want to purge the database?"),
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

  void _onPurge(BuildContext context) async {
    final shouldPurge = await showConfirmPurge(context);

    if (shouldPurge == true) {
      purgeEventRequest().then((res) {
        if (res != HttpStatus.ok) {
          showNetworkError(res, context);
        } else {
          onPurge?.call();
          showDialog(
            context: context,
            builder: (BuildContext context) => const AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  Text(
                    "Purge Success",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text("The event has successfully been purged"),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.buttonHeight(context, 1),
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        ),
        onPressed: () => _onPurge(context),
        icon: const Icon(Icons.warning, color: Colors.white),
        label: const Text(
          "Purge",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

void showNetworkError(int res, BuildContext context, {String subMessage = ""}) {
  String message = "";
  switch (res) {
    case HttpStatus.badRequest:
      message = "(400) Bad request: $subMessage";
      break;
    case HttpStatus.unauthorized:
      message = "(401) Unauthorized: $subMessage";
      break;

    default:
      message = "($res) Server error: $subMessage";
  }

  showDialog(
    context: context,
    builder: ((context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text(
              "Error",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          )
        ],
      );
    }),
  );
}

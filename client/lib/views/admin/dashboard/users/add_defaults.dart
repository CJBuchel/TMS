import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddDefaults extends StatelessWidget {
  final Function() onAddDefaults;
  const AddDefaults({Key? key, required this.onAddDefaults}) : super(key: key);

  // create default users
  void addDefaults(BuildContext context) {
    List<User> defaultUsers = [];

    defaultUsers.addAll([
      User(
        password: "password",
        permissions: Permissions(admin: false, headReferee: true),
        username: "head_referee",
      ),
      User(
        password: "password",
        permissions: Permissions(admin: false, referee: true),
        username: "referee",
      ),
      User(
        password: "password",
        permissions: Permissions(admin: false, judgeAdvisor: true),
        username: "judge_advisor",
      ),
      User(
        password: "password",
        permissions: Permissions(admin: false, judge: true),
        username: "judge",
      ),
    ]);

    // replace users
    bool success = true;
    for (var user in defaultUsers) {
      // delete user
      deleteUserRequest(user.username).then((delValue) {
        // add user
        addUserRequest(user).then((value) {
          if (value != HttpStatus.ok) {
            showNetworkError(value, context, subMessage: "Error adding ${user.username}");
            success = false;
          }
        });
      });
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully added default users"),
          backgroundColor: Colors.green,
        ),
      );
    }
    onAddDefaults();
  }

  void _addDefaultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              Text("Add Default Users?"),
            ],
          ),
          content: const Text("This will add the default users to the database, and replace any same named users. Do you want to continue?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addDefaults(context);
              },
              child: const Text("Add Defaults", style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_box_outlined),
      label: const Text("Add Defaults"),
      onPressed: () => _addDefaultsDialog(context),
    );
  }
}

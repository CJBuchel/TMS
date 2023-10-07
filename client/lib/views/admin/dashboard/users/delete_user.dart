import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class DeleteUser extends StatelessWidget {
  final Function() onDeleteUser;
  final String username;

  const DeleteUser({
    Key? key,
    required this.onDeleteUser,
    required this.username,
  }) : super(key: key);

  void _deleteUser(BuildContext context) {
    deleteUserRequest(username).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error deleting $username");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted $username"),
            backgroundColor: Colors.green,
          ),
        );
      }

      onDeleteUser();
    });
  }

  void _deleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              Text("Delete User?"),
            ],
          ),
          content: Text("Are you sure you want to delete $username?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(context);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
      onPressed: () => _deleteUserDialog(context),
    );
  }
}

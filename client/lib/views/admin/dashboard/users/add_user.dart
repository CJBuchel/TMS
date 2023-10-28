import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class AddUser extends StatelessWidget {
  final Function() onAddUser;
  AddUser({Key? key, required this.onAddUser}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _addUser(BuildContext context) {
    User user = User(
      username: _usernameController.text,
      password: _passwordController.text,
      permissions: Permissions(
        admin: false,
      ),
    );

    // add user
    addUserRequest(user).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error adding ${user.username}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added ${user.username}"),
            backgroundColor: Colors.green,
          ),
        );
      }

      onAddUser();
    });
  }

  void _addUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add, color: Colors.green),
              Text("Add User"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      hintText: 'Enter Username e.g `harry`',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter Password e.g `password1!`',
                    ),
                  ),
                ),
              ],
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
                _addUser(context);
                Navigator.of(context).pop();
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
      icon: const Icon(Icons.add, color: Colors.green),
      onPressed: () => _addUserDialog(context),
    );
  }
}

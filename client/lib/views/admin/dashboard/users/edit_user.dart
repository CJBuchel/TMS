import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditUser extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Function() onEditUser;
  final User originUser;
  EditUser({Key? key, required this.onEditUser, required this.originUser}) : super(key: key) {
    _usernameController.text = originUser.username;
    _passwordController.text = originUser.password;
  }

  void _addUser(BuildContext context) {
    User user = User(
      username: _usernameController.text,
      password: _passwordController.text,
      permissions: originUser.permissions,
    );

    // add user
    updateUserRequest(originUser.username, user).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error updating ${originUser.username}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated ${user.username}"),
            backgroundColor: Colors.green,
          ),
        );
      }

      onEditUser();
    });
  }

  void _addUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              Text("Edit User"),
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
              child: const Text("Update", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () => _addUserDialog(context),
    );
  }
}

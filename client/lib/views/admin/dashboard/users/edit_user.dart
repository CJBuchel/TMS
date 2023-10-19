import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_error_popup.dart';
import 'package:tms/utils/permissions_utils.dart';

class _PermissionCheckbox extends StatefulWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _PermissionCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  _PermissionCheckboxState createState() => _PermissionCheckboxState();
}

class _PermissionCheckboxState extends State<_PermissionCheckbox> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label),
        Checkbox(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value!;
              widget.onChanged(value);
            });
          },
        ),
      ],
    );
  }
}

class EditUser extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final PermissionController _permissionController = PermissionController(Permissions(admin: false));

  final Function() onEditUser;
  final User originUser;
  EditUser({Key? key, required this.onEditUser, required this.originUser}) : super(key: key) {
    _usernameController.text = originUser.username;
    _passwordController.text = originUser.password;
    _permissionController.perms = originUser.permissions;
  }

  List<Widget> _getPermissionCheckboxes() {
    return [
      _PermissionCheckbox(
        label: "Admin",
        value: _permissionController.value.admin,
        onChanged: (value) {
          _permissionController.setAdmin(value);
        },
      ),
      _PermissionCheckbox(
        label: "Head Referee",
        value: _permissionController.value.headReferee ?? false,
        onChanged: (value) {
          _permissionController.setHeadReferee(value);
        },
      ),
      _PermissionCheckbox(
        label: "Referee",
        value: _permissionController.value.referee ?? false,
        onChanged: (value) {
          _permissionController.setReferee(value);
        },
      ),
      _PermissionCheckbox(
        label: "Judge Advisor",
        value: _permissionController.value.judgeAdvisor ?? false,
        onChanged: (value) {
          _permissionController.setJudgeAdvisor(value);
        },
      ),
      _PermissionCheckbox(
        label: "Judge",
        value: _permissionController.value.judge ?? false,
        onChanged: (value) {
          _permissionController.setJudge(value);
        },
      ),
    ];
  }

  void _updateUser(BuildContext context) {
    User user = User(
      username: _usernameController.text,
      password: _passwordController.text,
      permissions: _permissionController.value,
    );

    // add user
    updateUserRequest(originUser.username, user).then((value) {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error updating ${originUser.username}");
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
                  padding: const EdgeInsets.only(top: 10),
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
                  padding: const EdgeInsets.only(top: 10),
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
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: _getPermissionCheckboxes(),
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
                _updateUser(context);
                Navigator.of(context).pop();
              },
              child: const Text("Update", style: TextStyle(color: Colors.red)),
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

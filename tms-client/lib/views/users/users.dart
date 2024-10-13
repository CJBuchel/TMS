import 'dart:io';

import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class Users extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<int> _insertUser(BuildContext context, String? userId, List<String> roles) async {
    if (_usernameController.text.isEmpty) {
      return HttpStatus.badRequest;
    } else {
      return await Provider.of<AuthProvider>(context, listen: false).insertUser(
        userId,
        User(
          username: _usernameController.text,
          password: _passwordController.text,
          roles: roles,
        ),
      );
    }
  }

  void _editUser(BuildContext context, User user) {
    String? userId = Provider.of<AuthProvider>(context, listen: false).getUserIdFromUsername(user.username);
    _usernameController.text = user.username;
    _passwordController.text = user.password;

    ConfirmFutureDialog(
      onStatusConfirmFuture: () => _insertUser(context, userId, user.roles),
      style: DialogStyle.success(
        title: "Edit User",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }

  void _addDefaultUsers(BuildContext context) {
    ConfirmFutureDialog(
      style: DialogStyle.warn(
        title: "Add default users",
        message: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to add default users?"),
            Text("Judge, Judge Advisor, Referee, Head Referee, ..."),
            Text("Default password is username"),
          ],
        ),
      ),
      onStatusConfirmFuture: () async {
        return await Provider.of<AuthProvider>(context, listen: false).insertDefaultUsers();
      },
    ).show(context);
  }

  void _addUser(BuildContext context) {
    _usernameController.clear();
    _passwordController.clear();
    ConfirmFutureDialog(
      onStatusConfirmFuture: () => _insertUser(context, null, []),
      style: DialogStyle.success(
        title: "Add User",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }

  void _removeUser(BuildContext context, User user) {
    ConfirmFutureDialog(
      style: DialogStyle.error(
        title: "Delete user",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to delete user: ${user.username}?"),
          ],
        ),
      ),
      onStatusConfirmFuture: () async {
        String? userId = Provider.of<AuthProvider>(context, listen: false).getUserIdFromUsername(user.username);
        if (userId != null) {
          return await Provider.of<AuthProvider>(context, listen: false).removeUser(userId);
        } else {
          TmsLogger().e("User: ${user.username} not found");
          return HttpStatus.notFound;
        }
      },
    ).show(context);
  }

  void _updateUserPermissions(BuildContext context, User user, UserPermissions permissions) async {
    UserPermissions updatedPermissions = user.getPermissions().getMergedPermissions(permissions: permissions);
    User updatedUser = User(username: user.username, password: user.password, roles: updatedPermissions.getRoles());
    String? userId = Provider.of<AuthProvider>(context, listen: false).getUserIdFromUsername(user.username);
    TmsLogger().i("User: ${user.username} permissions updated: ${permissions.admin}");
    var status = await Provider.of<AuthProvider>(context, listen: false).insertUser(userId, updatedUser);
    SnackBarDialog.fromStatus(message: "Update ${user.username}", status: status).show(context);
  }

  // padded cell
  BaseTableCell _cell(Widget child) {
    return BaseTableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }

  List<EditTableRow> _rows(BuildContext context, List<User> users) {
    // remove public/admin users from list
    users.removeWhere((u) => u.username == "public" || u.username == "admin");
    return users.map((u) {
      UserPermissions permissions = UserPermissions.fromRoles(roles: u.roles);

      return EditTableRow(
        onDelete: () => _removeUser(context, u),
        onEdit: () => _editUser(context, u),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        cells: [
          // username
          _cell(Text(u.username)),
          // admin
          _cell(LiveCheckbox(
            defaultValue: permissions.admin,
            onChanged: (v) => _updateUserPermissions(context, u, UserPermissions(admin: v)),
          )),
          // head referee
          _cell(LiveCheckbox(
            defaultValue: permissions.headReferee,
            onChanged: (v) => _updateUserPermissions(context, u, UserPermissions(headReferee: v)),
          )),
          // referee
          _cell(LiveCheckbox(
            defaultValue: permissions.referee,
            onChanged: (v) => _updateUserPermissions(context, u, UserPermissions(referee: v)),
          )),
          // judge advisor
          _cell(LiveCheckbox(
            defaultValue: permissions.judgeAdvisor,
            onChanged: (v) => _updateUserPermissions(context, u, UserPermissions(judgeAdvisor: v)),
          )),
          // judge
          _cell(LiveCheckbox(
            defaultValue: permissions.judge,
            onChanged: (v) => _updateUserPermissions(context, u, UserPermissions(judge: v)),
          )),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":users"],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    overlayColor: Colors.deepOrange,
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text("Add default users"),
                  onPressed: () => _addDefaultUsers(context),
                ),
              ),
            ],
          ),
          Selector<AuthProvider, List<User>>(
            selector: (context, authProvider) => authProvider.users,
            shouldRebuild: (previous, next) => !listEquals(previous, next),
            builder: (_, users, __) {
              return EditTable(
                onAdd: () => _addUser(context),
                headers: [
                  _cell(
                    const Text(
                      "Username",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _cell(
                    const Text(
                      "Admin",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _cell(
                    const Text(
                      "Head Referee",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _cell(
                    const Text(
                      "Referee",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _cell(
                    const Text(
                      "Judge Advisor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _cell(
                    const Text(
                      "Judge",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: _rows(context, users),
              );
            },
          ),
        ],
      ),
    );
  }
}

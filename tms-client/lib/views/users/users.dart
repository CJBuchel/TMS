import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class Users extends StatelessWidget {
  void _updateUserPermissions(BuildContext context, User user, UserPermissions permissions) async {
    UserPermissions updatedPermissions = user.getPermissions().getMergedPermissions(permissions: permissions);
    User updatedUser = User(username: user.username, password: user.password, roles: updatedPermissions.getRoles());
    String? userId = Provider.of<AuthProvider>(context, listen: false).getUserIdFromUsername(user.username);
    TmsLogger().i("User: ${user.username} permissions updated: ${permissions.admin}");
    await Provider.of<AuthProvider>(context, listen: false).insertUser(userId, updatedUser);
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
    return users.map((u) {
      UserPermissions permissions = UserPermissions.fromRoles(roles: u.roles);

      return EditTableRow(
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
      child: Selector<AuthProvider, List<User>>(
        selector: (context, authProvider) => authProvider.users,
        shouldRebuild: (previous, next) => !listEquals(previous, next),
        builder: (_, users, __) {
          return EditTable(
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
    );
  }
}

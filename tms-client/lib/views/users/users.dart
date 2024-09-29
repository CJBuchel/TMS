import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class Users extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":users"],
      child: Selector<AuthProvider, List<User>>(
        selector: (context, authProvider) => authProvider.users,
        builder: (_, users, __) {
          return EditTable(
            headers: [
              const BaseTableCell(child: const Text("Username")),
            ],
            rows: users.map((u) {
              return EditTableRow(
                cells: [
                  BaseTableCell(child: Text(u.username)),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

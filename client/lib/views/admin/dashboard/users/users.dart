import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/user_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/users/add_defaults.dart';
import 'package:tms/views/admin/dashboard/users/add_user.dart';
import 'package:tms/views/admin/dashboard/users/delete_user.dart';
import 'package:tms/views/admin/dashboard/users/edit_user.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  // [username, permission_checkboxes -> [admin, head_referee, referee, judge_advisor, judge]]

  List<User> _users = [];

  void fetchUsers({bool displayError = true}) {
    List<User> users = [];
    getUsersRequest().then((result) {
      if (result.item1 != HttpStatus.ok) {
        if (displayError) showNetworkError(result.item1, context);
      } else {
        users = result.item2;
        if (mounted && !listEquals(users, _users)) {
          setState(() {
            _users = users;
          });
        }
      }
    });
  }

  void _fetchUsersBinding() {
    fetchUsers(displayError: false);
  }

  @override
  void initState() {
    super.initState();
    // fetch users after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUsers(displayError: false); // don't display error on first fetch
    });

    NetworkHttp.httpState.addListener(_fetchUsersBinding);
    NetworkWebSocket.wsState.addListener(_fetchUsersBinding);
    NetworkSecurity.securityState.addListener(_fetchUsersBinding);
    NetworkAuth.loginState.addListener(_fetchUsersBinding);
  }

  @override
  void dispose() {
    NetworkHttp.httpState.removeListener(_fetchUsersBinding);
    NetworkWebSocket.wsState.removeListener(_fetchUsersBinding);
    NetworkSecurity.securityState.removeListener(_fetchUsersBinding);
    NetworkAuth.loginState.removeListener(_fetchUsersBinding);
    super.dispose();
  }

  void updateUserPermissions(User user) async {
    updateUserRequest(user.username, user).then((value) async {
      if (value != HttpStatus.ok) {
        showNetworkError(value, context, subMessage: "Error updating ${user.username}");
      } else {
        fetchUsers();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated ${user.username}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  bool _boolNullCheck(bool? value) {
    return value ?? false;
  }

  List<DataCell> getCheckboxes({User? user}) {
    if (user != null) {
      return [
        DataCell(
          Center(
            child: Checkbox(
              value: _boolNullCheck(user.permissions.admin),
              onChanged: (value) {
                user.permissions.admin = _boolNullCheck(value);
                updateUserPermissions(user);
              },
            ),
          ),
        ), // admin
        DataCell(
          Center(
            child: Checkbox(
              value: _boolNullCheck(user.permissions.headReferee),
              onChanged: (value) {
                user.permissions.headReferee = _boolNullCheck(value);
                updateUserPermissions(user);
              },
            ),
          ),
        ), // head referee
        DataCell(
          Center(
            child: Checkbox(
              value: _boolNullCheck(user.permissions.referee),
              onChanged: (value) {
                user.permissions.referee = _boolNullCheck(value);
                updateUserPermissions(user);
              },
            ),
          ),
        ), // referee
        DataCell(
          Center(
            child: Checkbox(
              value: _boolNullCheck(user.permissions.judgeAdvisor),
              onChanged: (value) {
                user.permissions.judgeAdvisor = _boolNullCheck(value);
                updateUserPermissions(user);
              },
            ),
          ),
        ), // judge advisor
        DataCell(
          Center(
            child: Checkbox(
              value: _boolNullCheck(user.permissions.judge),
              onChanged: (value) {
                user.permissions.judge = _boolNullCheck(value);
                updateUserPermissions(user);
              },
            ),
          ),
        ), // judge
      ];
    } else {
      return [
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
      ];
    }
  }

  DataRow2 _styledRow(User user) {
    return DataRow2(
      cells: [
        DataCell(
          Center(
            child: DeleteUser(
              username: user.username,
              onDeleteUser: () {
                fetchUsers();
              },
            ),
          ),
        ),
        DataCell(Text(user.username)),
        if (!Responsive.isMobile(context)) ...getCheckboxes(user: user),
        DataCell(
          Center(
            child: EditUser(
              onEditUser: () => fetchUsers(),
              originUser: user,
            ),
          ),
        ),
      ],
    );
  }

  List<DataRow2> getRows() {
    List<DataRow2> rows = [];
    for (var user in _users) {
      rows.add(_styledRow(user));
    }

    // row for adding new user
    rows.add(
      DataRow2(
        cells: [
          DataCell(
            Center(child: AddUser(onAddUser: () => fetchUsers())),
          ),
          // blank spaces for checkboxes
          const DataCell(SizedBox.shrink()),
          if (!Responsive.isMobile(context)) ...getCheckboxes(),
          const DataCell(SizedBox.shrink()),
        ],
      ),
    );

    return rows;
  }

  List<DataColumn2> getCheckboxHeaders() {
    return const [
      DataColumn2(label: Center(child: Text('Admin'))),
      DataColumn2(label: Center(child: Text('Head Referee'))),
      DataColumn2(label: Center(child: Text('Referee'))),
      DataColumn2(label: Center(child: Text('Judge Advisor'))),
      DataColumn2(label: Center(child: Text('Judge'))),
    ];
  }

  Widget usersTable() {
    return DataTable2(
      columns: [
        const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S), // delete button
        const DataColumn2(label: Text('Username'), size: ColumnSize.L),
        if (!Responsive.isMobile(context)) ...getCheckboxHeaders(),
        const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S), // edit button
      ],
      rows: getRows(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Column(
          children: [
            // top buttons
            SizedBox(
              width: constraints.maxWidth * 0.9,
              height: 100,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // refresh button/fetch users
                    IconButton(
                      onPressed: () {
                        fetchUsers();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.orange),
                    ),

                    // setup defaults button
                    AddDefaults(
                      onAddDefaults: () {
                        // fetch users after 1 second
                        Future.delayed(const Duration(seconds: 1), () {
                          fetchUsers();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // table
            SizedBox(
              width: constraints.maxWidth * 0.9,
              height: constraints.maxHeight - 100,
              child: Center(
                child: usersTable(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/utils/permissions.dart';
import 'package:tms/views/view_selector/admin_views.dart';

class ViewSelector extends StatelessWidget {
  const ViewSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ListView(
          children: <Widget>[
            // admin views
            if (authProvider.hasAccess(const Permissions(admin: true))) const AdminViews(),
          ],
        );
      },
    );
  }
}

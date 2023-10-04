import 'package:flutter/material.dart';
import 'package:tms/views/admin/dashboard/side_menu.dart';
import 'package:tms/views/shared/tool_bar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TmsToolBar(displayMenuButton: true),
      drawer: SideMenu(),
      body: Center(
        child: Text('Dashboard'),
      ),
    );
  }
}

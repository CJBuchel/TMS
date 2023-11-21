import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/admin/dashboard/overview/overview.dart';
import 'package:tms/views/admin/dashboard/side_menu.dart';
import 'package:tms/views/shared/error_handlers.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget? _view;

  void switchView(Widget view) {
    if (mounted) {
      setState(() {
        _view = view;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // after the first frame set state to dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // default view
      switchView(const Overview());
    });
  }

  Widget? _displayView() {
    if (Responsive.isMobile(context)) {
      return const MobileNotImplemented();
    } else {
      return _view;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(displayMenuButton: true),
      drawer: SideMenu(onView: (view) => switchView(view)),
      body: _displayView(),
    );
  }
}

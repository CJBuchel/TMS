import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/judge_advisor/ja_handler.dart';
import 'package:tms/views/judge_advisor/side_menu.dart';
import 'package:tms/views/shared/error_handlers.dart';
import 'package:tms/views/shared/tool_bar.dart';

class JudgeAdvisor extends StatefulWidget {
  const JudgeAdvisor({Key? key}) : super(key: key);

  @override
  State<JudgeAdvisor> createState() => _JudgeAdvisorState();
}

class _JudgeAdvisorState extends State<JudgeAdvisor> {
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
    _view = const JAHandler(); // default view
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
      drawer: JudgeAdvisorSideMenu(onView: (view) => switchView(view)),
      body: _displayView(),
    );
  }
}

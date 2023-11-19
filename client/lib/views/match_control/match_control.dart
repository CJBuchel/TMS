import 'package:flutter/material.dart';

import 'package:tms/views/match_control/match_control_handler.dart';
import 'package:tms/views/match_control/side_menu.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';

class MatchControl extends StatefulWidget {
  const MatchControl({Key? key}) : super(key: key);

  @override
  State<MatchControl> createState() => _MatchControlState();
}

class _MatchControlState extends State<MatchControl> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switchView(const MatchControlHandler());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(displayMenuButton: true),
      drawer: MatchSideMenu(onView: (view) => switchView(view)),
      body: _view,
    );
  }
}

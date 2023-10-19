import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/error_handlers.dart';
import 'package:tms/views/shared/tool_bar.dart';

class JudgeScoring extends StatelessWidget {
  const JudgeScoring({Key? key}) : super(key: key);

  Widget _displayView(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const MobileNotImplemented();
    } else {
      return const NotImplemented();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: _displayView(context),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class ScreenSelector extends StatefulWidget {
  ScreenSelector({super.key});

  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: TmsToolBar(),
    ));
  }
}

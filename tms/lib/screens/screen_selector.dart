import 'package:flutter/material.dart';
import 'package:tms/screens/shared/app_bar.dart';

class ScreenSelector extends StatefulWidget {
  TmsToolBar toolBar;
  ScreenSelector({super.key, required this.toolBar});

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
      appBar: widget.toolBar,
    ));
  }
}

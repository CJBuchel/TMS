import 'package:flutter/material.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class Setup extends StatelessWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            "Setup",
            style: TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }
}

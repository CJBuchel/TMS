import 'package:flutter/material.dart';

class ReadyMatchButton extends StatelessWidget {
  Widget _buttons(BuildContext context) {
    return Text("Ready/Unready");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),

      // ready/unready button
      child: _buttons(context),
    );
  }
}

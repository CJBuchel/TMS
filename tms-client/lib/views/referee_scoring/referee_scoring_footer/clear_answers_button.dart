import 'package:flutter/material.dart';

class ClearAnswersButton extends StatelessWidget {
  final double buttonHeight;

  ClearAnswersButton({
    Key? key,
    this.buttonHeight = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 10, right: 15),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.clear),
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        ),
        label: const Text("Clear"),
      ),
    );
  }
}

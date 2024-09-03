import 'package:flutter/material.dart';

class SubmitAnswersButton extends StatelessWidget {
  final double buttonHeight;

  SubmitAnswersButton({
    Key? key,
    this.buttonHeight = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send),
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
        ),
        label: const Text("Submit"),
      ),
    );
  }
}

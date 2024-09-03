import 'package:flutter/material.dart';

class NoShowButton extends StatelessWidget {
  final double buttonHeight;

  NoShowButton({
    Key? key,
    this.buttonHeight = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.no_accounts),
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
        ),
        label: const Text("No Show"),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';

class SetupClearButton extends StatelessWidget {
  final Function? onClear;

  const SetupClearButton({
    Key? key,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.buttonHeight(context, 1),
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
        ),
        onPressed: () => onClear?.call(),
        icon: const Icon(Icons.clear, color: Colors.white),
        label: const Text(
          "Clear",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class ErrorDialog extends BaseDialog {
  ErrorDialog({
    required String title,
    required String message,
  }) : super(title: _buildTitle(title), content: Center(child: Text(message)));

  static Widget _buildTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.error, color: Colors.red),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.red, fontSize: 21),
        ),
      ],
    );
  }
}

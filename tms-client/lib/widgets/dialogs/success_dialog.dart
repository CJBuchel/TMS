import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class SuccessDialog extends BaseDialog {
  SuccessDialog({
    required String title,
    required String message,
  }) : super(title: _buildTitle(title), content: Center(child: Text(message)));

  static Widget _buildTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.task_alt, color: Colors.green),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.green, fontSize: 21),
        ),
      ],
    );
  }
}

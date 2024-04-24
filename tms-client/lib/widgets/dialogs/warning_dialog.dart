import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class WarningDialog extends BaseDialog {
  WarningDialog({
    required String title,
    required String message,
  }) : super(title: _buildTitle(title), content: Center(child: Text(message)));

  static Widget _buildTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.warning, color: Colors.orange),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.orange, fontSize: 21),
        ),
      ],
    );
  }
}

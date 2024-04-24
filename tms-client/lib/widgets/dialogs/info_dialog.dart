import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class InfoDialog extends BaseDialog {
  InfoDialog({
    required String title,
    required String message,
  }) : super(title: _buildTitle(title), content: Center(child: Text(message)));

  static Widget _buildTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.info, color: Colors.blue),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.blue, fontSize: 21),
        ),
      ],
    );
  }
}

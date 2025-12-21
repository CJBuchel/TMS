import 'package:flutter/material.dart';

enum DialogType {
  error,
  info,
  success,
  warn;

  IconData get icon {
    switch (this) {
      case DialogType.error:
        return Icons.error;
      case DialogType.info:
        return Icons.info;
      case DialogType.warn:
        return Icons.warning;
      case DialogType.success:
        return Icons.check_circle;
    }
  }
}

abstract class BaseDialog {
  void show(BuildContext context);
}

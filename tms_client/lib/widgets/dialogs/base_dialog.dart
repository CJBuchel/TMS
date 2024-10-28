import 'package:flutter/material.dart';

enum DialogType { error, info, success, warn }

abstract class BaseDialog {
  void show(BuildContext context);
}

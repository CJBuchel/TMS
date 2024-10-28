import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class DialogStyle {
  final String title;
  final Widget message;
  final DialogType type;

  DialogStyle._({required this.title, required this.message, required this.type});

  static DialogStyle _scrollWrapper({required String title, required Widget message, required DialogType type}) {
    return DialogStyle._(title: title, message: SingleChildScrollView(child: message), type: type);
  }

  factory DialogStyle.info({required String title, required Widget message}) {
    return _scrollWrapper(title: title, message: message, type: DialogType.info);
  }

  factory DialogStyle.success({required String title, required Widget message}) {
    return _scrollWrapper(title: title, message: message, type: DialogType.success);
  }

  factory DialogStyle.error({required String title, required Widget message}) {
    return _scrollWrapper(title: title, message: message, type: DialogType.error);
  }

  factory DialogStyle.warn({required String title, required Widget message}) {
    return _scrollWrapper(title: title, message: message, type: DialogType.warn);
  }
}

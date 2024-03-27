import 'package:flutter/material.dart';

void pushTo(BuildContext context, String named) {
  if (ModalRoute.of(context)?.settings.name != named) {
    Navigator.pushNamed(context, named);
  } else {
    Navigator.pop(context);
  }
}

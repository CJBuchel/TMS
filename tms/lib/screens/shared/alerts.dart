import 'package:flutter/material.dart';

class BasicAlert extends StatelessWidget {
  const BasicAlert({super.key, required this.title, required this.subText});

  final String title;
  final String subText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(subText)),
    );
  }
}

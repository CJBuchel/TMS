import 'package:flutter/material.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;

  const BaseScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsAppBar(),
      body: child,
    );
  }
}

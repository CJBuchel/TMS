import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';
import 'package:tms/widgets/base_responsive.dart';

class BaseScaffold extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const BaseScaffold({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseResponsive(
      child: Scaffold(
        appBar: TmsAppBar(state: this.state),
        body: child,
      ),
    );
  }
}

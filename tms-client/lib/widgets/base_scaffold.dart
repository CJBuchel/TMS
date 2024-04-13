import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const BaseScaffold({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.builder(
      // portrait breakpoints
      breakpoints: [
        const Breakpoint(start: 0, end: 600, name: MOBILE),
        const Breakpoint(start: 601, end: 820, name: TABLET), // ipad air is 820 in portrait
        const Breakpoint(start: 821, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: 'XL'),
      ],

      child: Scaffold(
        appBar: TmsAppBar(state: this.state),
        body: child,
      ),
    );
  }
}

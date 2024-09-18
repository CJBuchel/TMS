import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class BaseResponsive extends StatelessWidget {
  final Widget child;

  const BaseResponsive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.builder(
      // portrait breakpoints
      breakpoints: [
        const Breakpoint(start: 0, end: 600, name: MOBILE),
        const Breakpoint(start: 601, end: 820, name: TABLET), // ipad air is 820 in portrait
        const Breakpoint(start: 821, end: double.infinity, name: DESKTOP),
        // const Breakpoint(start: 1921, end: double.infinity, name: 'XL'),
      ],

      // landscape breakpoints
      // breakpointsLandscape: [
      //   const Breakpoint(start: 0, end: 820, name: MOBILE),
      //   const Breakpoint(start: 821, end: 1024, name: TABLET),
      //   const Breakpoint(start: 1024, end: 1920, name: DESKTOP),
      //   const Breakpoint(start: 1921, end: double.infinity, name: 'XL'),
      // ],

      child: child,
    );
  }
}

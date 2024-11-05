import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/router.dart';
import 'package:tms/tms_theme.dart';

class TMSApp extends StatefulWidget {
  const TMSApp({super.key});

  @override
  State<TMSApp> createState() => _TMSAppState();

  // static accessor
  static _TMSAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_TMSAppState>()!;
  }
}

class _TMSAppState extends State<TMSApp> {
  ThemeMode _themeMode = TmsLocalStorageProvider().themeMode; // default for now
  ThemeMode get themeMode => _themeMode;

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
      //   const Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
      //   // const Breakpoint(start: 1921, end: double.infinity, name: 'XL'),
      // ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false, // gets in the way of the login button
        title: 'TMS Client',
        theme: tmsLightTheme, // light theme
        darkTheme: tmsDarkTheme, // dark theme
        themeMode: _themeMode, // theme mode (light or dark)
        routerConfig: tmsRouter,
      ),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
      TmsLocalStorageProvider().themeMode = themeMode;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/router.dart';
import 'package:tms/tms_theme.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';

class TMSApp extends StatefulWidget {
  const TMSApp({super.key});

  @override
  State<TMSApp> createState() => _TMSAppState();

  // static accessor
  static State<TMSApp> of(BuildContext context) {
    return context.findAncestorStateOfType<_TMSAppState>()!;
  }
}

class _TMSAppState extends State<TMSApp> {
  ThemeMode _themeMode = ThemeMode.dark; // default for now
  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // gets in the way of the login button
      title: 'TMS Client',
      theme: tmsLightTheme, // light theme
      darkTheme: tmsDarkTheme, // dark theme
      themeMode: _themeMode, // theme mode (light or dark)
      routerConfig: tmsRouter,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: Scaffold(
          appBar: const TmsAppBar(),
          body: child,
        ),

        // portrait breakpoints
        breakpoints: [
          const Breakpoint(start: 0, end: 600, name: MOBILE),
          const Breakpoint(start: 601, end: 820, name: TABLET), // ipad air is 820 in portrait
          const Breakpoint(start: 821, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: 'XL'),
        ],
      ),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/tms_theme.dart';
import 'package:tms/views/view_selector.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const ViewSelector(),
    ),
  ],
);

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
      debugShowCheckedModeBanner: true, // set this to false in the future
      title: 'TMS Client',
      theme: tmsLightTheme, // light theme
      darkTheme: tmsDarkTheme, // dark theme
      themeMode: _themeMode, // theme mode (light or dark)
      routerConfig: _router,
      builder: (context, child) {
        return Scaffold(
          body: child,
        );
      },
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}

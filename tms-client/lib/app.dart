import 'package:flutter/material.dart';
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // gets in the way of the login button
      title: 'TMS Client',
      theme: tmsLightTheme, // light theme
      darkTheme: tmsDarkTheme, // dark theme
      themeMode: _themeMode, // theme mode (light or dark)
      routerConfig: tmsRouter,
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
      TmsLocalStorageProvider().themeMode = themeMode;
    });
  }
}

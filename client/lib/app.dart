import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms/constants.dart';
import 'package:tms/screens/admin/setup.dart';
import 'package:tms/screens/connection.dart';
import 'package:tms/screens/timer/timer.dart';
import 'package:tms/screens/user/login.dart';
import 'package:tms/screens/user/logout.dart';
import 'package:tms/screens/selector/screen_selector.dart';

class TMSApp extends StatelessWidget {
  const TMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppTheme.isDarkTheme; // trigger getter for local storage
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkThemeNotifier,
      builder: (context, darkThemeSelected, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TMS Client',
          theme: ThemeData(
            brightness: brightness,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
              bodyColor: textColor,
              fontFamily: defaultFontFamily,
            ),
            canvasColor: bgSecondaryColor,
            // visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          // Main Router
          routes: {
            '/': (context) => const ScreenSelector(),

            // Utility screens
            '/server_connection': (context) => const Connection(),
            '/login': (context) => Login(),
            '/logout': (context) => const Logout(),

            // basic screens
            '/timer': (context) => const Timer(),

            // admin screens
            '/admin/setup': (context) => const Setup(),
          },
        );
      },
    );
  }
}

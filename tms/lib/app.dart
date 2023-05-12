import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms/constants.dart';
import 'package:tms/screens/connection.dart';
import 'package:tms/screens/login/login.dart';
import 'package:tms/screens/login/logout.dart';
import 'package:tms/screens/selector/screen_selector.dart';

class TMSApp extends StatelessWidget {
  const TMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'TMS Client',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white, fontFamily: defaultFontFamily),
        canvasColor: secondaryColor,
      ),

      // Main Router

      routes: {
        '/': (context) => ScreenSelector(),
        '/server_connection': (context) => const Connection(),
        '/login': (context) => Login(),
        '/logout': (context) => Logout()
      },
    );
  }
}

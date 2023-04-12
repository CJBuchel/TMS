import 'package:tms/constants.dart';
import 'package:tms/controllers/MenuAppController.dart';
import 'package:tms/landing.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TMSApp extends StatefulWidget {
  TMSApp({super.key});

  @override
  _TMSAppState createState() => _TMSAppState();
}

class _TMSAppState extends State<TMSApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'TMS Client',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),

      // Home screen (starter)
      // home: MultiProvider(
      //   providers: [
      //     ChangeNotifierProvider(
      //       create: (context) => MenuAppController(),
      //     ),
      //   ],
      //   child: MainScreen(),
      // ),

      // Main Router
      routes: {
        '/': (context) => Landing(),
        // '/dashboard': (context) => MultiProvider(providers: [ChangeNotifierProvider(create: (context) => Men)])
      },
    );
  }
}

void main() {
  runApp(TMSApp());
}

import 'package:tms/constants.dart';
import 'package:tms/controllers/MenuAppController.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Landing extends StatefulWidget {
  Landing({super.key});

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    var imageSize = <double>[300, 500];
    double textSize = 25;
    double buttonWidth = 250;
    double buttonHeight = 50;
    if (Responsive.isTablet(context)) {
      imageSize = [150, 300];
      textSize = 15;
      buttonWidth = 200;
    } else if (Responsive.isMobile(context)) {
      imageSize = [100, 250];
      textSize = 11;
      buttonWidth = 150;
      buttonHeight = 40;
    }
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // y axis
        children: <Widget>[
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // x axis
            crossAxisAlignment: CrossAxisAlignment.center, // y axis
            children: <Widget>[
              Image.asset(
                'assets/logos/TMS_LOGO.png',
                height: imageSize[0],
                width: imageSize[1],
              )
            ],
          ),
          // Address input
          Row(
            children: const <Widget>[
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 25),
                  child: TextField(
                    decoration:
                        InputDecoration(border: OutlineInputBorder(), labelText: 'Server Address', hintText: 'Enter the address of the server'),
                  ),
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                // padding: const EdgeInsets.only(top: 10),
                // decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: Text(
                    'Scan for Server',
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                  ),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                // padding: const EdgeInsets.only(top: 10),
                // decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                  label: Text(
                    'Connect',
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

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

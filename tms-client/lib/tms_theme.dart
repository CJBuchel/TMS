import 'package:flutter/material.dart';

///
/// Light theme
///
final ThemeData tmsLightTheme = ThemeData(
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme.light(),
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2697FF),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  secondaryHeaderColor: const Color(0xFFEEEEEE),
  canvasColor: const Color(0xFFEEEEEE),
  cardColor: const Color.fromRGBO(225, 245, 254, 1),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[900],
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: MaterialStateProperty.all<double>(0.0),
      backgroundColor: MaterialStateProperty.all<Color?>(Colors.white),
      foregroundColor: MaterialStateProperty.all<Color?>(Colors.blue),
      overlayColor: MaterialStateProperty.all<Color?>(Colors.lightBlue[50]),
      enableFeedback: true,
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.blue),
        ),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: const TextStyle(color: Colors.black),
    contentTextStyle: const TextStyle(color: Colors.black),
    surfaceTintColor: Colors.blue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color?>(Colors.blue),
      overlayColor: MaterialStateProperty.all<Color?>(Colors.lightBlue[50]),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle: TextStyle(color: Colors.black),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blue,
        width: 2.0,
      ),
    ),
  ),
);

///
/// Dark theme
///
final ThemeData tmsDarkTheme = ThemeData.dark().copyWith(
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
  colorScheme: const ColorScheme.dark(),
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 76, 119, 159),
  scaffoldBackgroundColor: const Color(0xFF212332),
  secondaryHeaderColor: const Color(0xFF2A2D3E),
  canvasColor: const Color(0xFF2A2D3E),
  cardColor: const Color.fromARGB(255, 69, 80, 100),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey[800],
    surfaceTintColor: Colors.blue,
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: MaterialStateProperty.all<double>(0.0),
      backgroundColor: MaterialStateProperty.all<Color?>(Colors.blue),
      foregroundColor: MaterialStateProperty.all<Color?>(Colors.white),
      overlayColor: MaterialStateProperty.all<Color?>(Colors.blue[800]),
      enableFeedback: true,
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.grey[900],
    titleTextStyle: const TextStyle(color: Colors.white),
    contentTextStyle: const TextStyle(color: Colors.white),
    surfaceTintColor: Colors.blue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color?>(Colors.blue),
      overlayColor: MaterialStateProperty.all<Color?>(Colors.lightBlue[50]),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle: TextStyle(color: Colors.white),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.blue,
        width: 2.0,
      ),
    ),
  ),
);

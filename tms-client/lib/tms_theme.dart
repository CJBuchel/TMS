import 'package:flutter/material.dart';

///
/// Light theme
///
final ThemeData tmsLightTheme = ThemeData.light().copyWith(
  textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
  colorScheme: const ColorScheme.light(),
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2697FF),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  secondaryHeaderColor: const Color(0xFFEEEEEE),
  canvasColor: const Color(0xFFEEEEEE),
  cardColor: const Color(0xFFE1F5FE),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[900],
    foregroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color?>(Colors.white),
      foregroundColor: WidgetStateProperty.all<Color?>(Colors.blue),
      overlayColor: WidgetStateProperty.all<Color?>(Colors.lightBlue[50]),
      enableFeedback: true,
      shape: WidgetStateProperty.all<OutlinedBorder>(
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
      foregroundColor: WidgetStateProperty.all<Color?>(Colors.blue),
      overlayColor: WidgetStateProperty.all<Color?>(Colors.lightBlue[50]),
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
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Colors.blue,
    selectionHandleColor: Colors.blue,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.blue[700],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFFFFFFFF),
  ),
);

///
/// Dark theme
///
final ThemeData tmsDarkTheme = ThemeData.dark().copyWith(
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
  colorScheme: const ColorScheme.dark(),
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF4C779F),
  scaffoldBackgroundColor: const Color(0xFF212332),
  secondaryHeaderColor: const Color(0xFF2A2D3E),
  canvasColor: const Color(0xFF2A2D3E),
  // cardColor: const Color.fromARGB(255, 69, 80, 100),
  cardColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey[800],
    surfaceTintColor: Colors.blue,
    foregroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all<double>(0.0),
      backgroundColor: WidgetStateProperty.all<Color?>(Colors.blue),
      foregroundColor: WidgetStateProperty.all<Color?>(Colors.white),
      overlayColor: WidgetStateProperty.all<Color?>(Colors.blue[800]),
      enableFeedback: true,
      shape: WidgetStateProperty.all<OutlinedBorder>(
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
      foregroundColor: WidgetStateProperty.all<Color?>(Colors.blue),
      overlayColor: WidgetStateProperty.all<Color?>(Colors.lightBlue[50]),
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
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionColor: Colors.blue,
    selectionHandleColor: Colors.blue,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF121212),
  ),
);

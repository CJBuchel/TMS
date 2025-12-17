import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';

final AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: primaryColor,
  surfaceTintColor: Colors.transparent,
  foregroundColor: Colors.white,
  centerTitle: true,
  iconTheme: IconThemeData(color: Colors.white),
);

final ElevatedButtonThemeData _elevatedButtonData = ElevatedButtonThemeData(
  style: ButtonStyle(
    elevation: WidgetStateProperty.all<double>(0.0),
    backgroundColor: WidgetStateProperty.all<Color?>(primaryColor),
    foregroundColor: WidgetStateProperty.all<Color?>(Colors.white),
    overlayColor: WidgetStateProperty.all<Color?>(primaryColor[800]),
    enableFeedback: true,
    shape: WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    error: supportErrorColor,
    surface: neutralColor[5],
  ),

  appBarTheme: _appBarTheme,
  elevatedButtonTheme: _elevatedButtonData,
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    error: supportErrorColor,
    surface: neutralColor,
  ),

  appBarTheme: _appBarTheme,
  elevatedButtonTheme: _elevatedButtonData,
);

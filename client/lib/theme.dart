import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';

ThemeData _buildTheme(Brightness brightness) {
  Color? surfaceColor = brightness == Brightness.dark
      ? neutralColor
      : neutralColor[5];

  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness,
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    error: supportErrorColor,
    surface: surfaceColor,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
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
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black26,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
    ),
  );
}

ThemeData get darkTheme => _buildTheme(Brightness.dark);
ThemeData get lightTheme => _buildTheme(Brightness.light);

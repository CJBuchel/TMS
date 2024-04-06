import 'package:flutter/material.dart';

final ThemeData tmsLightTheme = ThemeData(
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(),
  brightness: Brightness.light,
  primaryColor: Color(0xFF2697FF),
  scaffoldBackgroundColor: Color(0xFFFFFFFF),
  secondaryHeaderColor: Color(0xFFEEEEEE),
  canvasColor: Color(0xFFEEEEEE),
  cardColor: Color.fromRGBO(225, 245, 254, 1),
);

final ThemeData tmsDarkTheme = ThemeData.dark().copyWith(
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
  colorScheme: ColorScheme.dark(),
  brightness: Brightness.dark,
  primaryColor: Color(0xFF2697FF),
  scaffoldBackgroundColor: Color(0xFF212332),
  secondaryHeaderColor: Color(0xFF2A2D3E),
  canvasColor: Color(0xFF2A2D3E),
  cardColor: Color.fromARGB(255, 69, 80, 100),
);

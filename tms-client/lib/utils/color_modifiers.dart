import 'package:flutter/material.dart';

Color darken(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final newHsl = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return newHsl.toColor();
}

Color lighten(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final newHsl = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return newHsl.toColor();
}

import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Manrope',
  scaffoldBackgroundColor: Color(0xFFF0F0ED),
  primaryColor: Color(0xFFBEEE02),
  colorScheme: ColorScheme(
    primary: Color(0xFFBEEE02),
    primaryContainer: Color(0xFF62770F),
    secondary: Color(0xFF62770F),
    secondaryContainer: Color(0xFF202411),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Manrope',
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Manrope',
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Manrope',
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(fontFamily: 'Manrope', color: Colors.black),
    bodyMedium: TextStyle(fontFamily: 'Manrope', color: Colors.black),
    bodySmall: TextStyle(fontFamily: 'Manrope', color: Colors.black),
  ),
);

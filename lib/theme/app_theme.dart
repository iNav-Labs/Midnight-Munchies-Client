import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6552FF);
  static const backgroundColor = Colors.white;
  static const textColor = Colors.black;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
    ),
  );
}
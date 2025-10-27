import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF54b46b))),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF54b46b),
    secondary: Color(0xFF54b46b),
    surface: Colors.black,
    onSurface: Colors.white,
    onSurfaceVariant: Color(0xFFbebebe),
    surfaceContainerHighest: Color(0xFF29292D),
  ).copyWith(error: const Color(0xFFdd3135)),
  popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.black,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 5)),
  dividerTheme:
      const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
);
